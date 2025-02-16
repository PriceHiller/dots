{
  config,
  inputs,
  pkgs,
  ...
}:
let
  gitea_host = "git.${config.networking.domain}";
  # TODO: Move this docker image out to a separate package and NixOS Module
  # Huge thank you to https://icewind.nl/entry/gitea-actions-nix/ -- wouldn't have figured this out
  # without that post 🙂
  base = import (inputs.nix + "/docker.nix") {
    inherit pkgs;
    name = "nix-ci-base";
    maxLayers = 10;
    extraPkgs = with pkgs; [
      nodejs_20
      bash
    ];
    nixConf = {
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        # insert any other binary caches here
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # insert the public keys for those binary caches here
      ];
      # allow using the new flake commands in our workflows
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
      pathsToLink = [ "/bin" ]; # add coreutuls (which includes sleep) to /bin
    };
  };
in
{
  virtualisation.oci-containers.containers = {
    "nix-runner" = {
      image = "nix-runner:latest";
      imageFile = runner;
      autoStart = false;
    };
  };

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
    gitea-actions-runner.instances = {
      default = {
        enable = true;
        url = config.services.gitea.settings.server.ROOT_URL;
        tokenFile = config.age.secrets.gitea-runner-token.path;
        name = "Default";
        settings = {
          runner.capacity = 8;
        };
        labels = [
          "default:docker://nix-runner:latest"
          "alpine:docker://alpine:latest"
          "debian:docker://debian:latest"
        ];
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
