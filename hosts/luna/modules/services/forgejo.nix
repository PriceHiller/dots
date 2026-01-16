{
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
      # TODO: Move this docker image out to a separate package and NixOS Module Huge thank you to
      # https://icewind.nl/entry/gitea-actions-nix/ -- wouldn't have figured this out without that
      # post 🙂
      base = import (inputs.nix + "/docker.nix") {
        inherit pkgs;
        name = "nix-ci-base";
        extraPkgs = with pkgs; [
          nodejs_20
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
      runner = pkgs.dockerTools.buildImage {
        name = "nix-runner";
        tag = "latest";

        fromImage = base;
        fromImageName = null;
        fromImageTag = "latest";

        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [ pkgs.coreutils-full ];
          # add coreutils (which includes sleep) to /bin
          pathsToLink = [ "/bin" ];
        };
      };

      forgejo-user = config.services.forgejo.user;
    in
    {
      virtualisation.oci-containers.containers = {
        "nix-runner" = {
          image = "nix-runner:latest";
          imageFile = runner;
          autoStart = false;
        };
        "debian" = {
          image = "debian:latest";
          pull = "newer";
          autoStart = false;
        };
        "alpine" = {
          image = "alpine:latest";
          pull = "newer";
          autoStart = false;
        };
        "ubuntu" = {
          image = "ubuntu:latest";
          pull = "newer";
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
          settings = {
            DEFAULT = {
              APP_NAME = "Forgejo";
            };
            service.DISABLE_REGISTRATION = true;
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
                runner.capacity = 16;
              };
              labels = [
                "default:docker://nix-runner:latest"
                "nix:docker://nix-runner:latest"
                "alpine:docker://alpine:latest"
                "debian:docker://debian:latest"
              ];
            };
          };
        };
        nginx.virtualHosts."${git_host}" = {
          serverAliases = [
            "forgejo.pricehiller.com"
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