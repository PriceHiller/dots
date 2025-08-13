{ inputs, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "price@pricehiller.com";
  };

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
      enableACME = true;
      root = inputs.blog.packages.${pkgs.system}.default;
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
