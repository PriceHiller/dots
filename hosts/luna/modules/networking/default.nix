{ hostname, ... }:
{
  networking = {
    hostName = hostname;
    domain = "pricehiller.com";
    timeServers = [
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org"
    ];
    useNetworkd = true;
  };
}