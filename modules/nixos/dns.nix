{
  inputs,
  lib,
  config,
  pkgs,
  clib,
  ...
}:
let
  cfg = config.ext.dns;
  mkEnabledOption =
    description:
    lib.options.mkOption {
      description = description;
      type = lib.types.bool;
      default = true;
    };
in
{
  options.ext.dns = {
    enable = lib.options.mkEnableOption "Enable DNS on system";
    dnscrypt = lib.options.mkOption {
      description = "DNSCrypt specific options";
      default = { };
      type = lib.types.submodule {
        options = {
          useIPv6 = mkEnabledOption "Whether to use IPv6 servers for queries";
          port = lib.options.mkOption {
            description = "Port to listen on";
            type = lib.types.port;
            default = 5300;
          };
        };
      };
    };
    doh = lib.options.mkOption {
      description = "DNS over HTTPS specific options";
      default = { };
      type = lib.types.submodule {
        options = {
          enable = lib.options.mkEnableOption "Enable DNS over HTTPS";
          port = lib.options.mkOption {
            description = "The port to use for DOH";
            type = lib.types.port;
            default = 3300;
          };
          privateKey = lib.options.mkOption {
            description = "The path to the private key";
            type = (lib.types.either lib.types.path lib.types.str);
          };
          publicKey = lib.options.mkOption {
            description = "The path to the public key";
            type = lib.types.pathInStore;
          };
        };
      };
    };
  };

  config =
    let
      ServiceDirName = "dnscrypt-proxy";
      getStatePath = path: "/var/lib/${ServiceDirName}/${path}";
      getCacheFile = fname: getStatePath fname;
      getLogFile = fname: "/var/log/${ServiceDirName}/${fname}";
      dnscryptPort = builtins.toString cfg.dnscrypt.port;
      privateCertKeyName = "local-certificate";
      privateCertKeyPath = "/var/lib/dnscrypt-proxy/${privateCertKeyName}";
    in

    lib.mkIf (cfg.enable) {
      # Ensure some directory are set correctly
      systemd.services.dnscrypt-proxy2.serviceConfig = {
        StateDirectory = ServiceDirName;
        LogDirectory = ServiceDirName;
      };

      security.pki.certificateFiles = [
        cfg.doh.publicKey
      ];

      networking = {
        useNetworkd = true;
        nameservers = lib.mkForce [
          "127.0.0.1"
          "::1"
        ];
      };
      services.resolved.enable = lib.mkForce false;
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
            "127.0.0.1#${dnscryptPort}"
            "::1#${dnscryptPort}"
          ];
        };
      };

      systemd.services.dnscrypt-proxy.serviceConfig =
        let
        in
        {
          LoadCredential = "${privateCertKeyName}:${cfg.doh.privateKey}";
          ExecStartPre = [
            "${pkgs.writeShellScriptBin "set-cred-path" ''
              ${pkgs.coreutils}/bin/ln -sf "$CREDENTIALS_DIRECTORY/${privateCertKeyName}" "${privateCertKeyPath}"
            ''}/bin/set-cred-path"
          ];
        };

      services.dnscrypt-proxy = {
        enable = true;
        # See https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
        settings = {
          listen_addresses = [
            "127.0.0.1:${dnscryptPort}"
            "[::1]:${dnscryptPort}"
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

          local_doh = {
            listen_addresses = [ "127.0.0.1:${builtins.toString cfg.doh.port}" ];
            path = "/dns-query";
            cert_file = cfg.doh.publicKey;
            cert_key_file = privateCertKeyPath;
          };
          query_log = {
            file = getLogFile "query.log";
          };

          dnscrypt_ephemeral_keys = true;

          cache = true;
          cache_size = (clib.pow 2 18);

          lb_strategy = "p3"; # Randomly choose from the fastest N servers
          lb_estimator = true;
          ipv6_servers = cfg.dnscrypt.useIPv6;
          block_ipv6 = !cfg.dnscrypt.useIPv6;

          doh_servers = false;
          dnscrypt_servers = true;

          require_dnssec = true;
          require_nolog = true;
          require_nofilter = true;

          monitoring_ui = {
            enabled = true;
            privacy_level = 0;
            enable_query_log = true;
            username = "";
            password = "";
            listen_address = "127.0.0.1:8080";
            max_query_log_entries = 1000;
            max_memory_mb = 128;
          };
        };
      };
    };
}
