{ hostname, ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  networking = {
    hostName = hostname;
    wireless.iwd = {
      enable = true;
      settings = {
        Settings = {
          AutoConnect = true;
          AlwaysRandomizeAddress = true;
          Hidden = true;
        };
      };
    };
  };
}