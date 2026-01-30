{ config, ... }:
{
  services.harmonia-dev = {
    cache = {
      enable = true;
      signKeyPaths = [
        config.age.secrets.nix-cache-signing-key.path
      ];
      settings = {
        bind = "[::1]:5091";
        priority = 10;
      };
    };
  };

  services.nginx.virtualHosts."nix.cache.pricehiller.com" = {
    forceSSL = true;
    locations."/" = {
      extraConfig = ''
        auth_basic "Password Required";
        auth_basic_user_file ${config.age.secrets.nginx-basic-auth.path};
      '';
      proxyPass = "http://${config.services.harmonia-dev.cache.settings.bind}";
    };
  };
}
