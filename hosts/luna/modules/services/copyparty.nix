{ config, clib, ... }:
let
  host = "127.0.0.1";
  port = 3210;
  anubis = config.services.anubis.instances.copyparty;
in
{
  age.secrets = {
    copyparty-users-price-pw = {
      owner = config.services.copyparty.user;
      group = config.services.copyparty.group;
    };
  };

  services.copyparty = {
    enable = true;
    openFilesLimit = 8192;
    settings = {
      i = host;
      p = [ port ];
      no-reload = true;
      hist = "/var/cache/copyparty";
      no-robots = true;
      z = true;
      rproxy = 1;
      unpost = 5 * 60;
      magic = true;
      ah-alg = "argon2";
      shr = "/share";
      hash-mt = 12;
      shr-adm = "price";
      chpw-no = "price";
      chpw = true;
      chpw-len = 12;
      usernames = true;
    };
    accounts = {
      price = {
        passwordFile = config.age.secrets.copyparty-users-price-pw.path;
      };
    };

    groups = {
      admin = [ "price" ];
    };

    volumes =
      let
        defaults = {
          access = {
            A = [ "@admin" ];
          };
          flags = {
            fk = 16;
            dk = 16;
            hardlink = true;
            chmod_d = "770";
            chmod_f = "640";
            safededup = true;
            dbd = "acid";
            e2d = true;
            df = "100g";
            e2ds = true;
            e2dsa = true;
            e2t = true;
            e2ts = true;
            norobots = true;
            xvol = true;
            srch_excl = ".*";
            dots = true;
          };
        };
        basePath = "/mnt/Store-1/persist/copyparty";
      in
      {
        "/" = {
          path = "${basePath}/root";
          flags = {
            dks = true;
          };
        };
      }
      |> builtins.mapAttrs (
        _: value:
        (clib.recursiveMerge [
          defaults
          value
        ])
      );
  };

  services.anubis.instances.copyparty = {
    settings = {
      TARGET = "http://${host}:${builtins.toString port}";
      BIND = ":8993";
      BIND_NETWORK = "tcp";
      DIFFICULTY = 12;
    };
    policy = {
      settings = {
        status_codes = {
          CHALLENGE = 200;
          DENY = 403;
        };
      };
      extraBots = [
        {
          import = "(data)/common/allow-private-addresses.yaml";
        }
        {
          name = "Block clients lacking modern Sec-Fetch-* headers";
          action = "DENY";
          expression.any = [
            ''!("Sec-Fetch-Dest" in headers)''
            ''!("Sec-Fetch-Mode" in headers)''
            ''!("Sec-Fetch-Site" in headers)''
          ];
        }
      ];
    };
  };

  services.nginx.virtualHosts = {
    "fs.pricehiller.com" = {
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://localhost${anubis.settings.BIND}";
          proxyWebsockets = true;
          extraConfig =
            # nginx
            ''
              # disable buffering
              client_max_body_size 0;
              proxy_buffering off;
              proxy_request_buffering off;
              # improve download speed from 600 to 1500 MiB/s
              proxy_buffers 32 8k;
              proxy_buffer_size 16k;
              proxy_busy_buffers_size 24k;

              uwsgi_read_timeout 24h;
              uwsgi_send_timeout 24h;
              client_body_timeout 24h;
              send_timeout 24h;
            '';
        };
      };
    };
  };

  environment.persistence.save.directories = [
    {
      directory = "/var/lib/copyparty";
      user = config.services.copyparty.user;
      group = config.services.copyparty.group;
      mode = "0700";
    }
  ];

  environment.persistence.ephemeral.directories = [
    {
      directory = "/var/cache/copyparty";
      user = config.services.copyparty.user;
      group = config.services.copyparty.group;
      mode = "0700";
    }
  ];
}
