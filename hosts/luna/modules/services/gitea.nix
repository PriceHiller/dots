{
  config,
  ...
}:
let
  gitea_host = "git.${config.networking.domain}";
in
{

  age.secrets.gitea-db-pass = {
    owner = config.services.gitea.user;
    group = config.services.gitea.group;
  };

  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [ config.services.gitea.user ];
      ensureUsers = [
        {
          name = config.services.gitea.database.user;
          ensureClauses = {
            login = true;
            createdb = true;
          };
          ensureDBOwnership = true;
        }
      ];
    };

    gitea = {
      appName = "Gitea";
      enable = true;
      dump.enable = true;
      database = {
        type = "postgres";
        passwordFile = config.age.secrets.gitea-db-pass.path;
      };
      settings = {
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
          DOMAIN = "${gitea_host}";
          HTTP_ADDR = "127.0.0.1";
          ROOT_URL = "https://${gitea_host}/";
          SSH_PORT = 2220;
          START_SSH_SERVER = true;
          DISABLE_QUERY_AUTH_TOKEN = true;
        };
        session.COOKIE_SECURE = true;
        "repository.upload".FILE_MAX_SIZE = 1024;
      };
    };
    nginx.virtualHosts."${gitea_host}" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/".proxyPass =
          "http://${config.services.gitea.settings.server.HTTP_ADDR}:${builtins.toString config.services.gitea.settings.server.HTTP_PORT}";
        "/robots.txt" = {
          extraConfig = ''
            return 200 "User-agent: *\nDisallow: /";
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.gitea.settings.server.SSH_PORT ];

  environment.persistence.save.directories = [
    {
      directory = config.services.gitea.stateDir;
      user = config.services.gitea.user;
      group = config.services.gitea.group;
    }
  ];
}