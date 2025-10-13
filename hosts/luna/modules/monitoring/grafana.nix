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
    {
      directory = config.services.vector.settings.data_dir;
      mode = "0700";
      user = "nobody";
      group = "nogroup";
    }
  ];

  systemd.services.alloy = {
    serviceConfig = {
      SupplementaryGroups = [
        "nginx"
      ];
      BindReadOnlyPaths = [
        "/var/log/nginx"
      ];
    };
  };
  systemd.services.vector = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.basic-auth-env.path;
      SupplementaryGroups = [
        "nginx"
        "systemd-journal"
        "adm"
      ];
      BindReadOnlyPaths = [
        "/var/log/nginx"
      ];
    };
  };
  services.vector = {
    enable = true;
    validateConfig = false;
    settings = {
      schema.log_namespace = true;
      api.enabled = true;
      data_dir = "/var/lib/private/vector/";

      sources = {
        source_journald = {
          type = "journald";
        };
        source_nginx = {
          type = "file";
          include = [
            "/var/log/nginx/access.log"
          ];
          ignore_older_secs = 86400;
        };
      };
      transforms = {
        transform_nginx = {
          inputs = [
            "source_nginx"
          ];
          type = "remap";
          source = # vrl
            ''
              . = string!(.)
              . = parse_json!(.)
              if .level == null && .status != null {
                .status, err = to_int(.status)
                if err == null && .status >= 500 {
                    .level = "error"
                } else {
                  .level = "info"
                }
              }

              %service_name = "nginx"
            '';
        };
        transform_journald = {
          inputs = [
            "source_journald"
          ];
          type = "remap";
          source = # vrl
            ''

              .message = string!(.)
              structured = parse_syslog(.message) ?? parse_key_value(.message) ?? {}

              if structured.level != null {
                .level = structured.level
              } else if structured.LEVEL != null {
                .level = structured.LEVEL
              } else if structured.priority != null {
                .level = to_syslog_level(to_int(structured.priority) ?? -1) ?? null
              } else if structured.PRIORITY != null {
                .level = to_syslog_level(to_int(structured.PRIORITY) ?? -1) ?? null
              }



              jmeta = %journald.metadata
              if jmeta == null {
                jmeta = {}
              }

              .boot_id = jmeta._BOOT_ID
              .cmdline = jmeta._BOOT_ID
              .unit = jmeta._SYSTEMD_UNIT
              .slice = jmeta._SYSTEMD_SLICE
              .machine_id = jmeta._MACHINE_ID
              .cmdline = jmeta._CMDLINE
              .hostname = jmeta._HOSTNAME
              .cgroup = jmeta._SYSTEMD_CGROUP
              .comm = jmeta._COMM
              .exe = jmeta._EXE
              .syslog_identifer = jmeta.SYSLOG_IDENTIFIER
              .syslog_facility = to_syslog_facility(to_int(jmeta.SYSLOG_FACILITY) ?? -1) ?? null

              %service_name = "journal"
            '';
        };
      };
      sinks = {
        sink_loki = {
          inputs = [
            "transform_*"
          ];
          type = "loki";
          labels = {
            service_name = "{{ %service_name }}";
            system_host = "${config.system.name}";
            nixos_system_rev = "${
              let
                self = inputs.self;
                rev =
                  self.rev or self.dirtyRev or self.lastModified or config.system.configurationRevision or "unknown";
              in
              rev
            }";
            nixos_state_verison = "${config.system.stateVersion}";
          };
          encoding.codec = "json";
          endpoint =
            let
              lcfg = config.services.loki.configuration.server;
            in
            "http://${lcfg.http_listen_address}:${builtins.toString lcfg.http_listen_port}";
          auth = {
            strategy = "basic";
            user = ''''${BASIC_AUTH_USERNAME}'';
            password = ''''${BASIC_AUTH_PASSWORD}'';
          };
        };
      };
    };
  };

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
