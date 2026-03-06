{
  inputs,
  pkgs,
  ...
}:
{
  services = {
    nginx.virtualHosts = {
      "price-hiller.com" = {
        forceSSL = true;
        useACMEHost = "pricehiller.com";
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
                  # Redirect any `index.html` matches to the directory
                  # > /some/path/index.html -> /some/path
                  # > /index.html -> /
                  rewrite ^(.*)/index.html$ $1 permanent;

                  # Strip '.html' from the end of urls
                  # > /some/file.html -> /some/file
                  rewrite ^(/.*)\.html(\?.*)?$ $1$2 permanent;

                  # Remove trailing slashes from URLs
                  # > /some/path/ -> /some/path
                  rewrite ^/(.*)/(\?.*)?$ /$1$2 permanent;

                  # Redirect any raw `/index` to `/` if `/index` doesnt exist
                  # > /some/path/index -> /some/path
                  # > /index -> /
                  # > (/path/index is a file & exists) /path/index -> /path/index
                  if (!-e $request_filename) {
                    rewrite ^(.*)/index$ /$1 permanent;
                  }

                  # Redirect any hits from `/articles/` to `/posts/` -- `/articles/` is no longer a valid URL
                  # > /articles/ -> /posts/
                  # > /articles/example-post -> /posts/example-post
                  rewrite  ^/articles/(.*)$ /posts/$1 permanent;
                  rewrite  ^/articles/?$ /posts/ permanent;

                  index index.html;
                  try_files $uri/index.html $uri.html $uri/ $uri =404;
                  # Revalidate the cache in the background and use the stale cache for a short while
                  # when the cache is being revalidated
                  add_header Cache-Control "public, max-age=${builtins.toString (60 * 1)}, stale-while-revalidate=${builtins.toString (60 * 14)}";
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
