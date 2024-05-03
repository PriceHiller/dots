{ hostname, ... }:

let
  networks_dhcp_use_dns = "no";
  networks_dhcp = "ipv4";
  networks_multicast_dns = "no";
  networks_ipv6_privacy = "yes";
  networks_ipv6_accept_ra = "yes";
  networks_network_config = {
    DHCP = networks_dhcp;
    MulticastDNS = networks_multicast_dns;
    IPv6PrivacyExtensions = networks_ipv6_privacy;
    IPv6AcceptRA = networks_ipv6_accept_ra;
  };
  resolved_nameservers = [
    "1.1.1.1#cloudflare-dns.com"
    "9.9.9.9#dns.quad9.net"
    "8.8.8.8#dns.google"
    "2606:4700:4700::1111#cloudflare-dns.com"
    "2620:fe::9#dns.quad9.net"
    "2001:4860:4860::8888#dns.google"
  ];
  resolved_fallback_nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
  ];
in
{
  systemd.network = {
    enable = true;
    # HACK: Disable wait-online, check in on https://github.com/NixOS/nixpkgs/pull/258680 &
    # https://github.com/NixOS/nixpkgs/issues/247608
    wait-online.enable = false;
    networks = {
      "10-wlan" = {
        matchConfig.Name = [ "wl*" ];
        networkConfig = networks_network_config;
        dhcpV4Config = {
          RouteMetric = 600;
          UseDNS = networks_dhcp_use_dns;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 600;
          UseDNS = networks_dhcp_use_dns;
        };
      };
      "10-ethernet" = {
        matchConfig.Name = [
          "en*"
          "eth*"
        ];
        networkConfig = networks_network_config;
        dhcpV4Config = {
          RouteMetric = 100;
          UseDNS = networks_dhcp_use_dns;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 100;
          UseDNS = networks_dhcp_use_dns;
        };
      };
      "10-wwan" = {
        matchConfig.Name = [ "ww*" ];
        networkConfig = networks_network_config;
        dhcpV4Config = {
          RouteMetric = 700;
          UseDNS = networks_dhcp_use_dns;
        };
        ipv6AcceptRAConfig = {
          RouteMetric = 700;
          UseDNS = networks_dhcp_use_dns;
        };
      };
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ];
    fallbackDns = resolved_fallback_nameservers;
    llmnr = "resolve";
    extraConfig = ''
      MulticastDNS=yes
      DNSOverTLS=yes
      CacheFromLocalhost=no
      Cache=yes
    '';
  };
  networking = {
    useNetworkd = true;
    enableIPv6 = true;
    nameservers = resolved_nameservers;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        2200
      ];
    };
    hostName = "${hostname}";
  };
}
