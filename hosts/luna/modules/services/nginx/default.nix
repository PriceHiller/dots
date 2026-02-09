{
  inputs,
  config,
  pkgs,
  ...
}:
{
  age.secrets.nginx-basic-auth = {
    owner = config.services.nginx.user;
    group = config.services.nginx.user;
  };

  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
  };

  environment.persistence.ephemeral.directories =
    let
      acmeCfg = config.security.acme;
      acmeUser = if acmeCfg.useRoot then "root" else "acme";
      acmeGroup = acmeCfg.defaults.group;
    in
    builtins.concatLists [
      [
        {
          directory = "/var/lib/acme";
          user = acmeUser;
          group = acmeGroup;
        }
      ]
      (
        acmeCfg.certs
        |> builtins.mapAttrs (
          _: val: {
            directory = val.directory;
            user = acmeUser;
            group = val.group;
            mode = "u=rwx,g=rx,o=";
          }
        )
        |> builtins.attrValues
      )
    ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx.virtualHosts = {
    "pricehiller.com" = {
      serverAliases = [
        "price-hiller.com"
      ];
      forceSSL = true;
      root = inputs.blog.packages.${pkgs.stdenv.hostPlatform.system}.default;
      locations =
        let
          wkd-default-cfg = ''
            default_type "application/octet-stream";
            add_header Access-Control-Allow-Origin * always;
            add_header Last-Modified "";
          '';
        in
        {
          "/" = {
            extraConfig =
              # nginx
              ''
                error_page 450 =450 @blocked;

                # Super short user agent, die
                if ($http_user_agent ~ "^.{0,8}$") {
                  return 405;
                }

                # Empty user agent, die
                if ($http_user_agent ~* "^\s*$") {
                    return 450;
                }

                # LLM, die
                if ($http_user_agent ~* ".*openai.*") {
                    return 450;
                }

                # LLM, die
                if ($http_user_agent ~* ".*anthropic.*") {
                    return 450;
                }

                # LLM, die
                if ($http_user_agent ~* ".*perplexity.*") {
                    return 450;
                }

                # Invalid domain to be a agent for (bad scraper), die
                if ($http_user_agent ~* ".*example\.com\.*") {
                    return 450;
                }

                # Trying to pull some shit, die
                if ($request_uri ~ ^/(.*)\.(php|cgi|env)(\?|$)) {
                  return 450;
                }

                if ($request_uri ~ ^/(.*)\.html(\?|$)) {
                    return 302 /$1;
                }
                try_files $uri $uri.html $uri/ =404;
                add_header Cache-Control "no-cache";
                add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
                add_header Cross-Origin-Opener-Policy "same-origin";
                add_header X-Frame-Options "SAMEORIGIN";
                etag on;
              '';
          };
          "@blocked" = {
            root = "${./blocked}";
            extraConfig =
              # nginx
              ''
                rewrite ^ /index.html break;
              '';
          };
          # Always cache assets that have a hashed filename output via astro.
          # Etag is good and all, but it kicks off a round trip request to the server which can
          # cause a flash of white if the external CSS sheets aren't loaded
          "~* \.(?:css|js|woff2?|png|jpe?g|gif|svg)$".extraConfig =
            # nginx
            ''
              expires 1y;
              add_header Cache-Control "public, max-age=31536000, immutable";
              etag off;
            '';
          "^~ /.well-known/openpgpkey/hu/" = {
            alias = "${./gpg-wkd}/$1";
            extraConfig = wkd-default-cfg;
          };
          "^~ /.well-known/openpgpkey/policy/hu/" = {
            alias = "${./gpg-wkd}/$1";
            extraConfig = wkd-default-cfg;
          };
          "= /.well-known/openpgpkey/policy" = {
            extraConfig = wkd-default-cfg;
            return = "200";
          };
        };
    };
  };

  environment.etc = {
    "fail2ban/filter.d/nginx-404s.conf".text = ''
      [Definition]
      failregex = ^\{.*"status":404,.*"remote_addr":"<HOST>".*\}$
      ignoreregex =
    '';

    "fail2ban/filter.d/nginx-evil.conf".text = ''
      [Definition]
      failregex = ^\{.*"status":450,.*"remote_addr":"<HOST>".*\}$
      ignoreregex =
    '';

    "fail2ban/filter.d/nginx-empty-user-agent.conf".text = ''
      [Definition]
      failregex = ^\{.*"http_user_agent":"\s*"\,.*"remote_addr":"<HOST>".*\}$
      ignoreregex =
    '';
  };

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.0.0/16"
      "127.0.0.1/8"
      "::1"
    ];
    jails = {
      nginx-too-many-404s.settings = {
        enabled = true;
        filter = "nginx-404s";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 5;
        findtime = "20m";
        bantime = "10m";
      };
      nginx-evil.settings = {
        enabled = true;
        filter = "nginx-evil";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 2;
        findtime = "1h";
        bantime = "10m";
      };
      nginx-empty-user-agent.settings = {
        enabled = true;
        filter = "nginx-empty-user-agent";
        logpath = "/var/log/nginx/access.log";
        backend = "auto";
        maxretry = 1;
        findtime = "1h";
        bantime = "10m";
      };
    };
  };
}
