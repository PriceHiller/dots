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
            extraConfig = ''
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
}