{ config, ... }:
{
  services.phobost-api = {
    enable = true;
    port = 9543;
  };

  services.nginx.virtualHosts."phobost-api.pricehiller.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass =
      "http://${config.services.phobost-api.host}:${builtins.toString config.services.phobost-api.port}";
  };
}
