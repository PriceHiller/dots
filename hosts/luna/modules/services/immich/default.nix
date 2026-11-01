{ config, ... }:
let
  immichCfg = config.services.immich;
in
{
  services.immich = {
    enable = true;
    database = {
      port = config.services.postgresql.settings.port;
    };
    accelerationDevices = null;
  };

  services.nginx.virtualHosts."immich.${config.networking.domain}" = {
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig =
        # nginx
        ''
          client_body_buffer_size 1000m;
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
    };
    locations."/.well-known/immich" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  environment.persistence.save.directories = [
    {
      directory = "${immichCfg.mediaLocation}";
      user = immichCfg.user;
      group = immichCfg.group;
      mode = "0770";
    }
  ];
}
