{ config, fqdn, ... }:
{
  services.lakewatch-api = {
    enable = true;
    db = {
      createService = true;
      passwordFile = config.age.secrets.lakewatch-db-pass.path;
    };
  };

  services.lakewatch-scraper = {
    enable = true;
    db = {
      passwordFile = config.age.secrets.lakewatch-db-pass.path;
    };
  };
  services.nginx.virtualHosts."lakewatch.${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://${config.services.lakewatch-api.host}:${builtins.toString config.services.lakewatch-api.port}";
  };
}
