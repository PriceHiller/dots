{
  self,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  options = {
    # All secrets starting with "forgejo-" are necessarily forgejo secrets and so we want to make
    # them owned by the forgejo service by default
    age.secrets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            config = lib.mkIf (lib.strings.hasPrefix "forgejo-" name) {
              owner = lib.mkDefault config.services.forgejo.user;
              group = lib.mkDefault config.services.forgejo.group;
              mode = "0400";
            };
          }
        )
      );
    };
  };

  config =
    let
      git_host = "git.${config.networking.domain}";
      runner = pkgs.dockerTools.streamLayeredImage {
        name = "nix-runner";
        tag = "latest";
        created = "@" + builtins.toString self.lastModified;
        config = {
          Entrypoint = [ (lib.getExe pkgs.bashInteractive) ];
        };
        fromImage = import (inputs.nix + "/docker.nix") {
          inherit pkgs;
          name = "nix-ci-base";
          extraPkgs = with pkgs; [
            coreutils-full
            nodejs
            bash
          ];
          nixConf = {
            sandbox = "true";
            experimental-features = [
              "pipe-operators"
              "nix-command"
              "flakes"
            ];
          };
        };
      };

      forgejo-user = config.services.forgejo.user;
    in
    {
      virtualisation.oci-containers.containers = {
        ${runner.imageName} = {
          imageStream = runner;
          image = "${runner.imageName}:${runner.imageTag}";
          autoStart = false;
        };
      };
      services = {
        forgejo = {
          enable = true;
          dump.enable = false;
          database = {
            type = "postgres";
            passwordFile = config.age.secrets.forgejo-db-pass.path;
          };
          # See https://forgejo.org/docs/next/admin/config-cheat-sheet/ for details
          settings = {
            DEFAULT = {
              APP_NAME = "Forgejo";
            };
            service = {
              DISABLE_REGISTRATION = true;
              ENABLE_NOTIFY_MAIL = true;
            };

            # Extend timeouts to 1 hour
            "git.timeout" = {
              DEFAULT = 3600;
              MIGRATE = 3600;
              MIRROR = 3600;
              CLONE = 3600;
              PULL = 3600;
              GC = 3600;
            };
            markup.ENABLED = true;
            mirror.DEFAULT_INTERVAL = "1h";
            server = {
              DOMAIN = "${git_host}";
              HTTP_ADDR = "127.0.0.1";
              ROOT_URL = "https://${git_host}/";
              SSH_PORT = (builtins.elemAt config.services.openssh.ports 0);
              START_SSH_SERVER = false;
              SSH_USER = config.services.forgejo.user;
              LANDING_PAGE = "/explore/repos";
            };
            session.COOKIE_SECURE = true;
            "repository.upload".FILE_MAX_SIZE = 1024;
            "markup.jupyter" = {
              ENABLED = true;
              FILE_EXTENSIONS = ".ipynb";
              RENDER_COMMAND = "${pkgs.jupyter}/bin/jupyter nbconvert --stdin --stdout --to html  --embed-images --template basic";
              IS_INPUT_FILE = false;
            };
            "markup.sanitizer.jupyter.img" = {
              ALLOW_DATA_URI_IMAGES = true;
            };
            mailer = {
              ENABLED = true;
              FROM = "forgejo@${config.networking.domain}";
              PROTOCOL = "sendmail";
              SENDMAIL_PATH = "${config.security.wrapperDir}/sendmail";
              SENDMAIL_ARGS = "--";
            };
          };
        };
        gitea-actions-runner = {
          package = pkgs.forgejo-runner;
          instances = {
            default = {
              enable = true;
              url = config.services.forgejo.settings.server.ROOT_URL;
              tokenFile = config.age.secrets.forgejo-runner-token.path;
              name = "Default";
              settings = {
                runner = {
                  capacity = 16;
                  envs = {
                    NIX_REMOTE = "daemon";
                  };
                };
                container =
                  let
                    ro_vols = [
                      "/nix/var/log"
                      "/nix/var/nix/db"
                      "/nix/var/nix/daemon-socket"
                      "/nix/store"
                    ];
                  in
                  {
                    valid_volumes = ro_vols;
                    options = let
                      volOpts = builtins.concatStringsSep "-v";
                    in "-v /nix/var/log:/nix/var/log:ro -v /nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro -v /nix/var/nix/db:/nix/var/nix/db:ro -v /nix/store:/nix/store:ro";
                  };
              };
              labels = [
                "default:docker://${runner.imageName}:${runner.imageTag}"
                "nix:docker://${runner.imageName}:${runner.imageTag}"
              ];
            };
          };
        };
        nginx.virtualHosts."${git_host}" = {
          serverAliases = [
            "forgejo.pricehiller.com"
            "gitea.pricehiller.com"
          ];
          forceSSL = true;
          locations = {
            "/".proxyPass =
              "http://${config.services.forgejo.settings.server.HTTP_ADDR}:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";
            "/robots.txt" = {
              extraConfig = ''
                return 200 "User-agent: *\nDisallow: /";
              '';
            };
          };
        };
      };

      systemd = {
        services = {
          gitea-runner-default = {
            wants = [ "forgejo.service" ];
            after = [ "forgejo.service" ];
          };
          forgejo.preStart =
            let
              adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
              passwordFile = config.age.secrets.forgejo-admin-pass.path;
              user = "price";
            in
            # bash
            ''
              ${adminCmd} create --admin --email "root@localhost" --username "${user}" --password "$(tr -d '\n' < ${passwordFile})" || true
            '';
        };
      };

      services.openssh.extraConfig = ''
        Match User ${config.services.forgejo.settings.server.SSH_USER}
          AuthorizedKeysFile ${config.users.users.${forgejo-user}.home}/.ssh/authorized_keys
      '';

      users.users.${config.services.forgejo.user} = {
        extraGroups = [
          # Need to allow the forgejo user access to the mail password, thus the addition to the
          # mail group
          config.meta.mail.group
        ];
      };

      services.openssh.settings.AllowUsers = [
        config.services.forgejo.settings.server.SSH_USER
      ];

      environment.persistence.save.directories = [
        {
          directory = config.services.forgejo.stateDir;
          user = config.services.forgejo.user;
          group = config.services.forgejo.group;
          mode = config.users.users.${forgejo-user}.homeMode;
        }
        {
          directory = "/var/lib/private/gitea-runner";
          user = "nobody";
          group = "nogroup";
          mode = "0700";
        }
      ];
    };

}
