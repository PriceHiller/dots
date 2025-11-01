{ config, lib, ... }:
{
  ext.services.vector = {
    enable = lib.mkForce false;
    environmentFile = config.age.secrets.basic-auth-env.path;
    settings = {
      sinks.loki.enable = true;
      collectors = {
        journald.enable = true;
      };
    };
  };
}