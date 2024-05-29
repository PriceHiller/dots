{ hostname, lib, ... }:

let
  default-network-cfg =
    let
      use-dhcp-dns = "no";
    in
    {
      networkConfig = {
        DHCP = "yes";
        MulticastDNS = "yes";
        IPv6PrivacyExtensions = "yes";
        IPv6AcceptRA = "yes";
      };
      dhcpV4Config = {
        RouteMetric = 600;
        UseDNS = use-dhcp-dns;
      };
      ipv6AcceptRAConfig = {
        RouteMetric = 600;
        UseDNS = use-dhcp-dns;
      };
    };
in
{
  systemd.network = {
    enable = true;
    networks = lib.attrsets.mapAttrs (name: value: value // default-network-cfg) {
      "10-wlan".matchConfig.Name = [ "wl*" ];
      "10-ethernet".matchConfig.name = [
        "en*"
        "eth*"
      ];
      "10-wwan".matchConfig.name = [ "ww*" ];
    };
  };

  services.resolved = {
    enable = true;
    domains = [ "~." ];
    extraConfig = ''
      DNS=2a07:e340::2#dns.mullvad.net 194.242.2.2#dns.mullvad.net
      FallbackDNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
      Cache=yes
      CacheFromLocalhost=no
      DNSSEC=allow-downgrade
      DNSOverTLS=yes
      MulticastDNS=yes
    '';
  };
  networking = {
    hostName = hostname;
    wireless.iwd.enable = true;
    useNetworkd = true;
  };
}