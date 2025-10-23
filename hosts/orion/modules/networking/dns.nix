{
  inputs,
  lib,
  config,
  pkgs,
  clib,
  ...
}:
let
  hasIPv6Internet = true;
  StateDirectory = "dnscrypt-proxy";
  getCacheFile = fname: "/var/lib/${StateDirectory}/${fname}";
  getLogFile = fname: "/var/log/dnscrypt-proxy/${fname}";
  dnscrypt_port = "5300";
  cert-key-name = "local-certificate";
  cert-key-path = "/var/lib/dnscrypt-proxy/${cert-key-name}";
  cert-pub-path = ../../files/localhost.pem;
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
      rebind-localhost-ok = true;
      cache-size = 0;
      log-queries = "proto";
      address = [
        "/.localhost/127.0.0.1"
      ];
      server = [
        "127.0.0.1#${dnscrypt_port}"
        "::1#${dnscrypt_port}"
      ];
    };
  };

  systemd.services.dnscrypt-proxy.serviceConfig = {
    LoadCredential = "${cert-key-name}:${config.age.secrets.local-certificate.path}";
    ExecStartPre = [
      "${pkgs.writeShellScriptBin "set-cred-path" ''
        ${pkgs.coreutils}/bin/ln -sf "$CREDENTIALS_DIRECTORY/${cert-key-name}" "${cert-key-path}"
      ''}/bin/set-cred-path"
    ];
  };

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

      monitoring_ui = {
        enabled = true;
        privacy_level = 0;
        enable_query_log = true;
        username = "";
        password = "";
        listen_address = "127.0.0.1:8080";
        max_query_log_entries = 100000;
        max_memory_mb = 128;
      };
      local_doh = {
        listen_addresses = [ "127.0.0.1:3000" ];
        path = "/dns-query";
        cert_file = cert-pub-path;
        cert_key_file = cert-key-path;
      };
      query_log = {
        file = getLogFile "query.log";
      };

      dnscrypt_ephemeral_keys = true;
      bootstrap_resolvers = [
        "194.242.2.2:53"
        "1.1.1.1:53"
        "192.71.166.92:53"
        "[2a03:f80:30:192:71:166:92:1]:53"
      ];

      cache = true;
      cache_size = (clib.pow 2 18);

      lb_strategy = "p5"; # Randomly choose from the fastest N servers
      lb_estimator = true;
      ipv6_servers = hasIPv6Internet;
      block_ipv6 = !hasIPv6Internet;

      doh_servers = false;
      dnscrypt_servers = true;

      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;
    };
  };

  age.secrets.local-certificate = {
    group = "nginx";
    mode = "0440";
  };

  services.nginx.virtualHosts = {
    "dnscrypt.localhost" = {
      forceSSL = false;
      enableACME = false;
      locations."/" = {
        proxyPass =
        "http://${config.services.dnscrypt-proxy.settings.monitoring_ui.listen_address}/";
        proxyWebsockets = true;
      };
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = StateDirectory;
}