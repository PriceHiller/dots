{ inputs, config, ... }:
let
  grafana_host = "grafana.${config.networking.domain}";
  grafana_loki_host = "loki.${config.networking.domain}";
in
{
  users.users.grafana.extraGroups = [
    config.meta.mail.group
  ];
  environment.persistence.save.directories = [
    {
      directory = config.services.grafana.dataDir;
      user = "grafana";
      group = "grafana";
    }
    {
      directory = config.services.loki.dataDir;
      user = "loki";
      group = "loki";
    }
  ];

  services = {
    loki = {
      enable = true;
      configuration =
        let
          dataDir = config.services.loki.dataDir;
        in
        {
          server = {
            http_listen_address = "127.0.0.1";
            http_listen_port = 3030;
          };
          auth_enabled = false;

          pattern_ingester.enabled = true;

          common = {
            path_prefix = "${dataDir}";
            ring = {
              kvstore.store = "inmemory";
            };
            storage = {
              filesystem = {
                chunks_directory = "${dataDir}/chunks";
                rules_directory = "${dataDir}/rules";
              };
            };
          };

          ingester = {
            lifecycler = {
              address = "127.0.0.1";
              ring = {
                kvstore = {
                  store = "inmemory";
                };
                replication_factor = 1;
              };
            };
            chunk_idle_period = "1h";
            max_chunk_age = "1h";
            chunk_target_size = 999999;
            chunk_retain_period = "30s";
          };

          schema_config = {
            configs = [
              {
                from = "2020-05-15";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };

          limits_config = {
            retention_period = "48h";
          };

          compactor = {
            working_directory = "${dataDir}/compactor";
            compactor_ring = {
              kvstore = {
                store = "inmemory";
              };
            };
          };
        };
    };
    grafana = {
      enable = true;
      settings = {
        analytics.reporting_enabled = false;
        smtp = {
          enabled = true;
          user = config.meta.mail.user;
          startTLS_policy = "NoStartTLS";
          host = config.meta.mail.connectionString;
          from_name = "Grafana";
          from_address = "grafana.${config.networking.hostName}@${config.meta.mail.mailDomain}";
          password = "$__file{${config.meta.mail.passwordPath}}";
        };
        server = {
          domain = "${grafana_host}";
          http_addr = "127.0.0.1";
          http_port = 2342;
        };
      };
    };

    nginx.virtualHosts = {
      "${grafana_host}" = {
        enableACME = true;
        acmeRoot = null;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${builtins.toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
      "${grafana_loki_host}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          auth_basic "Password Required";
          auth_basic_user_file ${config.age.secrets.nginx-basic-auth.path};
        '';
        locations."/" = {
          proxyPass = "http://${config.services.loki.configuration.server.http_listen_address}:${builtins.toString config.services.loki.configuration.server.http_listen_port}/";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}
