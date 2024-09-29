{ hostname, ... }:
{
  services.resolved = {
    enable = true;
    domains = [ "~." ];
    dnsovertls = "true";
    dnssec = "false";
  };
  networking = {
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
    hostName = hostname;
    nameservers = [
      "194.242.2.2#dns.mullvad.net"
      "2a07:e340::2#dns.mullvad.net"
      "91.239.100.100#anycast.uncensoreddns.org"
      "2001:67c:28a4::#anycast.uncensoreddns.org"
    ];
    useNetworkd = true;
  };
}
