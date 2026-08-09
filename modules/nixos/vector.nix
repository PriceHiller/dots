{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.ext.services.vector;
  nginxCfg = cfg.settings.collectors.nginx;
  journaldCfg = cfg.settings.collectors.journald;
in
{
  imports = [
    ./logviewer.nix
  ];

  options.ext.services.vector = {
    enable = lib.options.mkEnableOption "Enable Vector log collection";
    dataDir = lib.options.mkOption {
      description = "The data directory to use for vector";
      type = lib.types.str;
      default = "/var/lib/private/vector";
    };

    persist = lib.options.mkOption {
      description = "Vector impermanence persistence options";
      default = { };
      type = lib.types.submodule {
        options = {
          enable = lib.options.mkOption {
            description = "Whether to use persist the Vector data directory when using impermanence";
            type = lib.types.bool;
            default = true;
          };
          attr = lib.options.mkOption {
            description = "The impermanence attr to use for persistence, will be used as `environment.persistence.\${attr}`";
            type = lib.types.str;
            default = "save";
          };
        };
      };
    };
    environmentFile = lib.options.mkOption {
      description = "The environment file to provide to the Vector systemd service. Should contain secrets to send data to Loki";
      type = lib.types.nullOr (lib.types.either (lib.types.path) (lib.types.str));
      default = null;
    };
    settings = lib.options.mkOption {
      description = "Collector & Sink settings";
      default = { };
      type = lib.types.submodule {
        options = {
          sinks = lib.options.mkOption {
            default = { };
            description = "Sink options";
            type = lib.types.submodule {
              options = {
                loki = lib.options.mkOption {
                  description = "Loki Sink options";
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      enable = lib.options.mkEnableOption "Enable a Loki sink";
                      endpoint = lib.options.mkOption {
                        description = "The endpoint to send Loki logs to";
                        type = lib.types.str;
                        default = "https://loki.pricehiller.com";
                      };
                    };
                  };
                };
              };
            };
          };
          collectors = lib.options.mkOption {
            description = "Collector options";
            default = { };
            type = lib.types.submodule {
              options = {
                journald = lib.options.mkOption {
                  description = "Journald collection options";
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkEnableOption "Enable journald log collection";
                    };
                  };
                };
                nginx = lib.options.mkOption {
                  description = "Nginx collection options";
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkEnableOption "Enable Nginx log collection";
                      logSocketPath = lib.options.mkOption {
                        description = "Path to the Nginx-to-Vector Unix socket";
                        type = lib.types.path;
                        default = "/run/vector-nginx/nginx.sock";
                        readOnly = true;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # ── Base Vector config  ──
      {
        ext.logviewer.enable = true;

        environment.persistence.${cfg.persist.attr}.directories = lib.mkIf cfg.persist.enable [
          {
            directory = cfg.dataDir;
            mode = "0700";
            user = "nobody";
            group = "nogroup";
          }
        ];

        systemd.services.vector = {
          after = [ config.ext.logviewer.serviceName ];
          serviceConfig = {
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
            SupplementaryGroups = [ config.ext.logviewer.group ];
          };
        };

        services.vector = {
          enable = true;
          validateConfig = false;
          settings = {
            schema.log_namespace = true;
            api.enabled = true;
            data_dir = cfg.dataDir;
            sinks.sink_loki = lib.mkIf cfg.settings.sinks.loki.enable {
              inputs = [ "*_sink" ];
              type = "loki";
              labels = {
                service_name = "svc-{{ %service_name }}";
                system_host = config.system.name;
                nixos_state_version = config.system.stateVersion;
              };
              structured_metadata = {
                nixos_system_rev =
                  let
                    self = inputs.self;
                  in
                  builtins.toString (
                    self.rev or self.dirtyRev or self.lastModified or config.system.configurationRevision or "unknown"
                  );
              };
              encoding.codec = "json";
              endpoint = cfg.settings.sinks.loki.endpoint;
              auth = {
                strategy = "basic";
                user = "\${BASIC_AUTH_USERNAME}";
                password = "\${BASIC_AUTH_PASSWORD}";
              };
            };
          };
        };
      }

      # ── Journald collector ──
      (lib.mkIf journaldCfg.enable {
        systemd.services.vector.serviceConfig.SupplementaryGroups = [ "systemd-journal" ];

        services.vector.settings.sources.source_journald = {
          type = "journald";
        };

        services.vector.settings.transforms.transform_journald_sink = {
          inputs = [ "source_journald" ];
          type = "remap";
          source = # vrl
            ''
              .message = string!(.)

              parsed, err = parse_json(.message)
              if err == null {
                .structured_message = parsed
              }

              jmeta = %journald.metadata
              if jmeta == null {
                jmeta = {}
              }

              .level = to_syslog_level(to_int(jmeta.PRIORITY) ?? -1) ?? null
              .stream_id = jmeta._STREAM_ID
              .boot_id = jmeta._BOOT_ID
              .unit = jmeta._SYSTEMD_UNIT
              .slice = jmeta._SYSTEMD_SLICE
              .machine_id = jmeta._MACHINE_ID
              .cmdline = jmeta._CMDLINE
              .pid = jmeta._PID
              .uid = jmeta._UID
              .gid = jmeta._GID
              .hostname = jmeta._HOSTNAME
              .cgroup = jmeta._SYSTEMD_CGROUP
              .comm = jmeta._COMM
              .rt_timestamp = jmeta.__REALTIME_TIMESTAMP
              .invocation_id = jmeta._SYSTEMD_INVOCATION_ID
              .exe = jmeta._EXE
              .syslog_identifier = jmeta.SYSLOG_IDENTIFIER
              .syslog_facility = to_syslog_facility(to_int(jmeta.SYSLOG_FACILITY) ?? -1) ?? null

              %service_name = "journal"
            '';
        };
      })

      # ── Nginx collector ──
      (lib.mkIf nginxCfg.enable {
        systemd.services.vector =
          let
            runtimeDir = (builtins.dirOf nginxCfg.logSocketPath);
          in
          {
            serviceConfig = {
              RuntimeDirectory = [ (builtins.baseNameOf runtimeDir) ];
              # Ensure Nginx can write its logs to the socket vector will read from
              ExecStartPre =
                let
                  setfacl = lib.getExe' pkgs.acl "setfacl";
                in
                [
                  "+${setfacl} --default --modify u:${config.services.nginx.user}:rw ${runtimeDir}"
                  "+${setfacl} --modify u:${config.services.nginx.user}:x ${runtimeDir}"
                ];
            };
          };

        # Nginx needs to start _after_ vector so the socket file exists and is writeable
        systemd.services.nginx = {
          after = [ "vector.service" ];
          wants = [ "vector.service" ];
        };

        services.vector.settings.sources.source_nginx = {
          type = "socket";
          mode = "unix_datagram";
          path = nginxCfg.logSocketPath;
          socket_file_mode = 504; # 0o0770
        };

        services.vector.settings.transforms.transform_nginx_sink = {
          inputs = [ "source_nginx" ];
          type = "remap";
          source = # vrl
            ''
              syslog = parse_syslog!(string!(.))
              msg = parse_json!(syslog.message)

              if msg.level == null && msg.status != null {
                status, err = to_int(msg.status)
                if err == null && status >= 500 {
                    msg.level = "error"
                } else {
                  msg.level = "info"
                }
                msg.status = status
              }

              . = msg

              ts, err = from_unix_timestamp(to_int!(.time_msec), unit: "milliseconds")
              if err == null {
                %timestamp = ts
              }
              %service_name = "nginx"
            '';
        };

        services.nginx.appendHttpConfig =
          let
            headersToNginxVars =
              prefix: headers:
              let
                toNginxVar = name: builtins.replaceStrings [ "-" ] [ "_" ] name;
                headerEntries = builtins.map (name: ''"${name}":"${prefix}${toNginxVar name}"'') headers;
              in
              "'" + builtins.concatStringsSep "," headerEntries + "'";
          in
          # nginx
          ''
            log_format vector-logger-json escape=json
              '{'
                '"time": "$time_iso8601",'
                '"time_msec": $msec,'
                '"status": $status,'
                '"host": "$host",'
                '"headers": {'
                  '"request": {'
                    ${headersToNginxVars "$http_" [
                      # Content negotiation & metadata
                      "host"
                      "content-type"
                      "content-length"
                      "accept"
                      "accept-language"
                      "accept-encoding"
                      "accept-charset"
                      "from"
                      "upgrade-insecure-requests"
                      "priority"

                      # Client identity & context
                      "user-agent"
                      "sec-ch-ua"
                      "sec-ch-ua-mobile"
                      "sec-ch-ua-platform"
                      "referer"
                      "origin"
                      "dnt"

                      # Caching
                      "cache-control"
                      "if-modified-since"
                      "if-none-match"

                      # Connection & transport
                      "connection"
                      "upgrade"
                      "te"
                      "via"
                      "range"

                      # Proxy & tracing
                      "x-forwarded-for"
                      "x-forwarded-proto"
                      "x-forwarded-host"
                      "x-request-id"
                      "forwarded"

                      # Sec-Fetch (browser-enforced)
                      "sec-fetch-dest"
                      "sec-fetch-mode"
                      "sec-fetch-site"
                      "sec-fetch-user"

                      # Extended Client Hints
                      "sec-ch-ua-full-version-list"
                      "sec-ch-ua-platform-version"
                      "sec-ch-ua-model"
                      "sec-ch-ua-arch"
                      "sec-ch-ua-bitness"

                      # Behavioural signals
                      "sec-gpc"
                      "sec-purpose"
                      "save-data"
                      "x-requested-with"

                      # Network hints
                      "device-memory"
                      "downlink"
                      "ect"
                      "rtt"
                    ]}
                  '},'
                  '"response": {'
                    ${headersToNginxVars "$sent_http_" [
                      "content-type"
                      "content-encoding"
                      "etag"
                      "cache-control"
                      "vary"
                      "location"
                    ]}
                  '}'
                '},'
                '"bytes_sent": $bytes_sent,'
                '"remote_addr": "$remote_addr",'
                '"uri": "$uri",'
                '"request_length": $request_length,'
                '"request_method": "$request_method",'
                '"request_uri": "$request_uri",'
                '"request_time": $request_time,'
                '"request_id": "$request_id",'
                '"server_protocol": "$server_protocol",'
                '"upstream_addr": "$upstream_addr",'
                '"ssl_protocol": "$ssl_protocol",'
                '"ssl_cipher": "$ssl_cipher",'
                '"connection_serial": $connection,'
                '"connection_requests": $connection_requests,'
                '"request_completion": "$request_completion",'
                '"pipe": "$pipe"'
              '}';

            access_log syslog:server=unix:${nginxCfg.logSocketPath} vector-logger-json;
          '';
      })

    ]
  );
}
