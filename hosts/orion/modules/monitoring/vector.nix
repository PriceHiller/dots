{ config, ... }:
{
  ext.services.vector = {
    enable = true;
    environmentFile = config.age.secrets.basic-auth-env.path;
    settings = {
      sinks.loki.enable = true;
      collectors = {
        journald.enable = true;
      };
    };
  };
}