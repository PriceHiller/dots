{ config, ... }:
let
  grafana_host = "grafana.${config.networking.domain}";
in
{

  users.users.grafana.extraGroups = [
    config.meta.mail.group
  ];

  services = {
    grafana = {
      enable = true;
      settings = {
        smtp = {
          enabled = true;
          user = config.meta.mail.user;
          startTLS_policy = "NoStartTLS";
          host = config.meta.mail.connectionString;
          from_name = "Grafana";
          from_address = "grafana.${config.networking.hostName}@${config.meta.mail.mailDomain}";
          password = "$__file{${config.meta.mail.passwordPath}}";
        };
        server = {
          domain = "${grafana_host}";
          http_addr = "127.0.0.1";
          http_port = 2342;
        };
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
