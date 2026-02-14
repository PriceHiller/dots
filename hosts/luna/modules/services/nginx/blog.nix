{
  inputs,
  pkgs,
  config,
  ...
}:
let
  anubisBlog = config.services.anubis.instances.blog;
in
{
  services = {
    # Anubis set up according to
    # https://anubis.techaro.lol/docs/admin/configuration/subrequest-auth
    anubis.instances.blog = {
      settings = {
        TARGET = " ";
        SERVE_ROBOTS_TXT = false;
        BIND_NETWORK = "tcp";
        BIND = ":8991";
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
            name = "Tries to access PHP";
            action = "DENY";
            expression = ''
              path.endsWith(".php")
            '';
          }
          {
            name = "Empty User Agent";
            action = "DENY";
            user_agent_regex = "^\s*$";
          }
        ];
      };
    };
    nginx.virtualHosts = {
      "pricehiller.com" = {
        default = true;
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
            # This allows Anubis to check the connection
            "^~ /.within.website" = {
              extraConfig =
                # nginx
                ''
                  proxy_pass http://localhost${anubisBlog.settings.BIND};
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  auth_request off;
                '';
            };
            "/" = {
              extraConfig =
                # nginx
                ''
                  auth_request /.within.website/x/cmd/anubis/api/check;
                  error_page 401 403 =200 /.within.website/?redir=$request_uri;

                  try_files $uri $uri.html $uri/ =404;
                  add_header Cache-Control "no-cache";
                  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
                  add_header Cross-Origin-Opener-Policy "same-origin";
                  add_header X-Frame-Options "SAMEORIGIN";
                  etag on;
                '';
            };
            # Always cache assets that have a hashed filename output via astro.
            # Etag is good and all, but it kicks off a round trip request to the server which can
            # cause a flash of white if the external CSS sheets aren't loaded
            "~* \.(?:css|js|woff2?|png|jpe?g|gif|svg|webp|avif)$".extraConfig =
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
  };
}
