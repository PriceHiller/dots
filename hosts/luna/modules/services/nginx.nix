{
  inputs,
  pkgs,
  fqdn,
  ...
}:
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
    defaults.email = "price@orion-technologies.io";
  };

  services.nginx.virtualHosts."blog.${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    root = inputs.blog.packages.${pkgs.system}.default;
    locations."/".index = "home.html";
  };
}
