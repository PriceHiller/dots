{
  self,
  config,
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
      runner = pkgs.dockerTools.buildLayeredImage {
        name = "nix-runner";
        tag = "latest";
        created = "@" + builtins.toString self.lastModified;
        contents = with pkgs; [
          coreutils-full
          nodejs
          bashInteractive
          openssh
          nix
          findutils
          curl
          wget
          gitMinimal
          less
          which
          gzip
          gnutar
          gnugrep
          dockerTools.binSh
          dockerTools.caCertificates
          dockerTools.usrBinEnv
          dockerTools.fakeNss
        ];
        config = {
          Entrypoint = [ "/bin/bash" ];
          Env = [
            "NIX_REMOTE=daemon"
          ];
        };
      };

      forgejo-user = config.services.forgejo.user;
    in
    {
      virtualisation.oci-containers.containers = {
        ${runner.imageName} = {
          imageFile = runner;
          image = "${runner.imageName}:${runner.imageTag}";
        };
      };

      services = {
        anubis.instances.forgejo = {
          settings = {
            TARGET = "http://${config.services.forgejo.settings.server.HTTP_ADDR}:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";
            BIND = ":8992";
            BIND_NETWORK = "tcp";
            DIFFICULTY = 12;
            COOKIE_DOMAIN = git_host;
          };
          policy = {
            extraBots = [
              {
                import = "(data)/common/allow-private-addresses.yaml";
              }
              {
                import = "(data)/clients/git.yaml";
              }
              {
                action = "WEIGH";
                expression = {
                  all = [
                    "\"User-Agent\" in headers"
                    "( userAgent.contains(\"Firefox\") ) || ( userAgent.contains(\"Chrome\") ) || ( userAgent.contains(\"Safari\") )"
                    "\"Accept\" in headers"
                    "\"Sec-Fetch-Dest\" in headers"
                    "\"Sec-Fetch-Mode\" in headers"
                    "\"Sec-Fetch-Site\" in headers"
                    "\"Accept-Encoding\" in headers"
                    "( headers[\"Accept-Encoding\"].contains(\"zstd\") || headers[\"Accept-Encoding\"].contains(\"br\") )"
                    "\"Accept-Language\" in headers"
                  ];
                };
                name = "realistic-browser-catchall";
                weight = {
                  adjust = -10;
                };
              }
              {
                action = "WEIGH";
                expression = "\"Upgrade-Insecure-Requests\" in headers";
                name = "upgrade-insecure-requests";
                weight = {
                  adjust = -2;
                };
              }
              {
                action = "WEIGH";
                expression = {
                  all = [
                    "userAgent.contains(\"Chrome\")"
                    "\"Sec-Ch-Ua\" in headers"
                    "headers[\"Sec-Ch-Ua\"].contains(\"Chromium\")"
                    "\"Sec-Ch-Ua-Mobile\" in headers"
                    "\"Sec-Ch-Ua-Platform\" in headers"
                  ];
                };
                name = "chrome-is-proper";
                weight = {
                  adjust = -5;
                };
              }
              {
                action = "WEIGH";
                expression = "!(\"Accept\" in headers)";
                name = "should-have-accept";
                weight = {
                  adjust = 5;
                };
              }
              {
                action = "WEIGH";
                name = "generic-browser";
                user_agent_regex = "Mozilla|Opera";
                weight = {
                  adjust = 10;
                };
              }
            ];
          };
        };

        forgejo = {
          enable = true;
          package = pkgs.forgejo;
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
            # Allow Nginx & Anubis to act as reverse proxies
            security = {
              REVERSE_PROXY_LIMIT = 2;
              REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,::1/128";
            };
          };
        };
        gitea-actions-runner = {
          package = pkgs.forgejo-runner;
          instances = {
            default = {
              enable = true;
              url = "http://${config.services.forgejo.settings.server.HTTP_ADDR}:${builtins.toString config.services.forgejo.settings.server.HTTP_PORT}";
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
                      "/nix"
                    ];
                  in
                  {
                    valid_volumes = ro_vols;
                    options = ro_vols |> builtins.map (vol: "-v ${vol}:${vol}:ro") |> builtins.concatStringsSep " ";
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
            "/" = {
              proxyPass = "http://127.0.0.1${builtins.toString config.services.anubis.instances.forgejo.settings.BIND}";
              proxyWebsockets = true;
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