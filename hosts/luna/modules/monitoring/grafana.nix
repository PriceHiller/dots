{ clib, config, ... }:
let
  grafana_host = "grafana.${config.networking.domain}";
  grafana_loki_host = "loki.${config.networking.domain}";
in
{
  users.users.grafana.extraGroups = [
    config.meta.mail.group
  ];

  age.secrets.grafana-secret-key = {
    owner = "grafana";
    mode = "0400";
  };

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
            grpc_listen_address = "127.0.0.1";
            grpc_server_max_recv_msg_size = 256 * (clib.pow 2 20); # 100 MiB
            grpc_server_max_send_msg_size = 256 * (clib.pow 2 20);
          };
          auth_enabled = false;

          pattern_ingester.enabled = true;
          analytics.reporting_enabled = false;

          common = {
            path_prefix = dataDir;
            instance_addr = "127.0.0.1";
            replication_factor = 1;
            ring.kvstore.store = "inmemory";
            storage.filesystem = {
              chunks_directory = "${dataDir}/chunks";
              rules_directory = "${dataDir}/rules";
            };
          };

          ingester = {
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
            retention_period = "0s";
            max_query_length = "0";
            retention_stream = [
              {
                selector = ''{level=~"(?i)debug|trace"}'';
                priority = 1;
                period = "48h";
              }
            ];
          };

          query_range.results_cache.cache.embedded_cache = {
            enabled = true;
            max_size_mb = 256;
            ttl = "24h";
          };

          compactor = {
            working_directory = "${dataDir}/compactor";
            retention_enabled = true;
            delete_request_store = "filesystem";
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
      provision = {
        enable = true;
        datasources.settings = {
          prune = true;
          datasources = [
            {
              name = "Loki";
              type = "loki";
              uid = "loki";
              url = "http://${config.services.loki.configuration.server.http_listen_address}:${toString config.services.loki.configuration.server.http_listen_port}";
              isDefault = true;
            }
          ];
        };
      };
      settings = {
        security = {
          secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
        };
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
          domain = grafana_host;
          http_addr = "127.0.0.1";
          http_port = 2342;
          root_url = "https://${grafana_host}";
          enforce_domain = true;
        };
        security.disable_gravatar = true;
        database.wal = true;
        analytics = {
          check_for_plugin_updates = false;
          check_for_updates = false;
          feedback_links_enabled = false;
          reporting_enabled = false;
        };
      };
    };

    nginx.virtualHosts = {
      "${grafana_host}" = {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${builtins.toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
      "${grafana_loki_host}" = {
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
