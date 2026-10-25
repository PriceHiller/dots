{ hostname, ... }:

{
  services.resolved = {
    enable = true;
    settings.Resolve = {
      Domains = [ "~." ];
      DNSOverTLS = "true";
      DNSSEC = true;
    };
  };
  networking = {
    hostName = hostname;
    domain = "pricehiller.com";
    nameservers = [
      "9.9.9.10#dns10.quad9.net"
      "149.112.112.10#dns10.quad9.net"
      "2620:fe::10#dns10.quad9.net"
      "2620:fe::fe:10#dns10.quad9.net"
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
