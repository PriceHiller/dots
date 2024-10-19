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
    defaults.email = "price@price-hiller.com";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx.virtualHosts = {
    "price-hiller.com" = {
      forceSSL = true;
      enableACME = true;
      root = inputs.blog.packages.${pkgs.system}.default;
      locations."/".extraConfig = ''
        if ($request_uri ~ ^/(.*)\.html(\?|$)) {
            return 302 /$1;
        }
        try_files $uri $uri.html $uri/ =404;
      '';
      locations."/".index = "home.html";
    };
  };
}