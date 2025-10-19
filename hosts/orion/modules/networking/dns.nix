{
  inputs,
  lib,
  config,
  ...
}:
let
  hasIPv6Internet = true;
  StateDirectory = "dnscrypt-proxy";
  getCacheFile = fname: "/var/lib/${StateDirectory}/${fname}";
  getLogFile = fname: "/var/log/dnscrypt-proxy/${fname}";
  dnscrypt_port = "5300";
in
{
  networking = {
    useNetworkd = true;
    nameservers = lib.mkForce [
      "127.0.0.1"
      "::1"
    ];
  };
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      # Explicitly specify the nameservers here so dnsmasq listens locally
      listen-address = config.networking.nameservers;
      bind-interfaces = true;
      stop-dns-rebind = true;
      address = [
        "/.localhost/127.0.0.1"
      ];
      server = [
        "127.0.0.1#${dnscrypt_port}"
        "::1#${dnscrypt_port}"
      ];
    };
  };
  # Pulled from https://wiki.nixos.org/wiki/Encrypted_DNS
  services.dnscrypt-proxy = {
    enable = true;
    # See https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
    settings = {
      listen_addresses = [
        "127.0.0.1:${dnscrypt_port}"
        "[::1]:${dnscrypt_port}"
      ];
      sources = {
        # See https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
        public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          cache_file = getCacheFile "public-resolvers.md";
        };
        relays = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
            "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
          ];
          cache_file = getCacheFile "relays.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 73;
          prefix = "";
        };
      };

      anonymized_dns = {
        skip_incompatible = true;
        routes = [
          {
            server_name = "*";
            via = [
              "*"
            ];
          }
        ];
      };

      blocked_names = {
        blocked_names_file = inputs.oisd-blocklist;
        log_file = getLogFile "blocked.log";
      };

      log_level = 2;

      monitoring_ui = {
        enabled = true;
        privacy_level = 0;
        username = "";
        password = "";
        listen_address = "127.0.0.1:8080";
        max_query_log_entries = 100000;
        max_memory_mb = 128;
      };
      query_log = {
        file = getLogFile "query.log";
      };

      cache_size = 16384;
      lb_strategy = "p10"; # Randomly choose from the fastest 10 servers
      ipv6_servers = hasIPv6Internet;
      block_ipv6 = !hasIPv6Internet;

      doh_servers = false;
      dnscrypt_servers = true;

      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;
    };
  };

  services.nginx.virtualHosts = {
    "dnscrypt.localhost" = {
      forceSSL = false;
      enableACME = false;
      locations."/".proxyPass =
        "http://${config.services.dnscrypt-proxy.settings.monitoring_ui.listen_address}/";
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = StateDirectory;

  # environment.persistence.ephemeral =
}
