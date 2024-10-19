{ config, ... }:
let
  grafana_host = "grafana.${config.networking.domain}";
in
{
  services = {
    grafana = {
      enable = true;
      settings.server = {
        domain = "${grafana_host}";
        http_addr = "127.0.0.1";
        http_port = 2342;
      };
    };

    nginx.virtualHosts."${grafana_host}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${builtins.toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}