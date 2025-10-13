{
  config,
  inputs,
  pkgs,
  lib,
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
      dump.enable = false;
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
          "nix:docker://nix-runner:latest"
          "alpine:docker://alpine:latest"
          "debian:docker://debian:latest"
        ];
      };
    };
    nginx.virtualHosts."${gitea_host}" = {
      serverAliases = [
        "git.price-hiller.com"
      ];
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

  systemd.services.gitea-runner-default.serviceConfig.ExecStartPre = lib.mkBefore [
    # HACK: Delay startup by 10 seconds. This should ensure that the gitea service is good to
    # go. This will make deployments delay by 10 seconds though if the runner is changed. I'm
    # willing to accept that trade off.
    "${pkgs.coreutils}/bin/sleep 10"
  ];

  environment.persistence.save.directories = [
    {
      directory = config.services.gitea.stateDir;
      user = config.services.gitea.user;
      group = config.services.gitea.group;
    }
    {
      directory = "/var/lib/private/gitea-runner";
      user = "nobody";
      group = "nogroup";
      mode = "0700";
    }
  ];
}
