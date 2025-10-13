{ config, ... }:
{
  ext.services.alloy = {
    enable = true;
    enableDefaultConfig = true;
    environmentFile = config.age.secrets.basic-auth-env.path;
  };
}
