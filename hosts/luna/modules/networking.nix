{ hostname, ... }:

{
  services.resolved = {
    enable = true;
    domains = [ "~." ];
    dnsovertls = "true";
    dnssec = "false";
  };
  networking = {
    hostName = hostname;
    domain = "pricehiller.com";
    nameservers = [
      "194.242.2.2#dns.mullvad.net"
      "2a07:e340::2#dns.mullvad.net"
      "91.239.100.100#anycast.uncensoreddns.org"
      "2001:67c:28a4::#anycast.uncensoreddns.org"
    ];
    timeServers = [
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org"
    ];
    useNetworkd = true;
  };
}