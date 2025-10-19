{ config, ... }:
{
  ext.services.vector = {
    enable = true;
    environmentFile = config.age.secrets.basic-auth-env.path;
    settings = {
      sinks.loki = {
        enable = true;
        endpoint =
          let
            lcfg = config.services.loki.configuration.server;
          in
          "http://${lcfg.http_listen_address}:${builtins.toString lcfg.http_listen_port}";
      };
      collectors = {
        journald.enable = true;
        nginx.enable = true;
      };
    };
  };
}
