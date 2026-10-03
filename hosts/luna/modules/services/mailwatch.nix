{ config, ... }:
{
  services.mailwatch = {
    enable = true;
    environmentFile = config.age.secrets.mailwatch-env-file.path;
  };
}
