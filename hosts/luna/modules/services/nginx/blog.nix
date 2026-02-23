{
  inputs,
  pkgs,
  ...
}:
{
  services = {
    nginx.virtualHosts = {
      "price-hiller.com" = {
        enableACME = true;
        globalRedirect = "pricehiller.com";
      };
      "pricehiller.com" = {
        default = true;
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
            "~* \/(assets|js)\/.*\.(?:css|js|woff2?|png|jpe?g|gif|svg|webp|avif)$".extraConfig =
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
