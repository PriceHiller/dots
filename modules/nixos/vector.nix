{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.ext.services.vector;
in
{
  options.ext.services.vector = {
    enable = lib.options.mkEnableOption "Enable OpenSSH server with some defaults enabled";
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
                      enable = lib.mkEnableOption "Enable Nginx log collection, this will also update the Nginx log format to emit json";
                      logPath = lib.options.mkOption {
                        description = "The log path to collect logs from";
                        type = lib.types.either (lib.types.str) (lib.types.path);
                        default = "/var/log/nginx/access.log";
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

  config = lib.mkIf (cfg.enable) {
    environment.persistence.${cfg.persist.attr}.directories = lib.mkIf (cfg.persist.enable) [
      {
        directory = cfg.dataDir;
        mode = "0700";
        user = "nobody";
        group = "nogroup";
      }
    ];

    systemd.services.vector = {
      serviceConfig = {
        EnvironmentFile = lib.mkIf (!(builtins.isNull cfg.environmentFile)) cfg.environmentFile;
        SupplementaryGroups = lib.mkMerge [
          (lib.mkIf cfg.settings.collectors.nginx.enable [ "nginx" ])
          (lib.mkIf cfg.settings.collectors.journald.enable [ "systemd-journal" ])
          [ "adm" ]
        ];
        BindReadOnlyPaths = lib.mkMerge [
          (lib.mkIf cfg.settings.collectors.nginx.enable [ "/var/log/nginx" ])
        ];
      };
    };

    services.vector = {
      enable = true;
      validateConfig = false;
      settings = {
        schema.log_namespace = true;
        api.enabled = true;
        data_dir = cfg.dataDir;
        sinks = {
          sink_loki = lib.mkIf (cfg.settings.sinks.loki.enable) {
            inputs = [
              "*_sink"
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
            endpoint = cfg.settings.sinks.loki.endpoint;
            auth = {
              strategy = "basic";
              user = ''''${BASIC_AUTH_USERNAME}'';
              password = ''''${BASIC_AUTH_PASSWORD}'';
            };
          };
        };
      };
    };

    services.vector.settings.sources.source_journald =
      lib.mkIf (cfg.settings.collectors.journald.enable)
        {
          type = "journald";
        };
    services.vector.settings.transforms.transform_journald_sink =
      lib.mkIf (cfg.settings.collectors.journald.enable)
        {
          inputs = [
            "source_journald"
          ];
          type = "remap";
          source = # vrl
            ''
              .message = string!(.)

              jmeta = %journald.metadata
              if jmeta == null {
                jmeta = {}
              }

              .level = to_syslog_level(to_int(jmeta.PRIORITY) ?? -1) ?? null
              .stream_id = jmeta._STREAM_ID
              .boot_id = jmeta._BOOT_ID
              .cmdline = jmeta._BOOT_ID
              .unit = jmeta._SYSTEMD_UNIT
              .slice = jmeta._SYSTEMD_SLICE
              .machine_id = jmeta._MACHINE_ID
              .cmdline = jmeta._CMDLINE
              .pid = jmeta._PID
              .uid = jmeta._UID
              .gid = jmeta._GID
              .stream_id = jmeta._STEAM_ID
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

    services.vector.settings.sources.source_nginx = lib.mkIf (cfg.settings.collectors.nginx.enable) {
      type = "file";
      include = [
        cfg.settings.collectors.nginx.logPath
      ];
      ignore_older_secs = 86400;
    };
    services.vector.settings.transforms.transform_nginx_sink =
      lib.mkIf (cfg.settings.collectors.nginx.enable)
        {

          inputs = [
            "source_nginx"
          ];
          type = "remap";
          source = # vrl
            ''
              msg = string!(.)
              msg = parse_json!(.)
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
              %service_name = "nginx"
            '';
        };
    services.nginx.appendHttpConfig =
      lib.mkIf (cfg.settings.collectors.nginx.enable)
        # nginx
        ''
          log_format logger-json escape=json '${
            # We remove the whitespace in the json log to ensure the json log comes out on a single line
            # in the system log
            builtins.replaceStrings [ "\n" " " ] [ "" "" ] ''
              {
                  "time": "$time_iso8601",
                  "time_msec": $msec,
                  "status": $status,
                  "http_user_agent": "$http_user_agent",
                  "http_host": "$http_host",
                  "http_referer": "$http_referer",
                  "bytes_sent": $bytes_sent,
                  "content_type": "$content_type",
                  "content_length": "$content_length",
                  "remote_addr": "$remote_addr",
                  "request_length": $request_length,
                  "request_method": "$request_method",
                  "request_uri": "$request_uri",
                  "request_time": $request_time,
                  "request_id": "$request_id",
                  "request": "$request",
                  "server_protocol": "$server_protocol",
                  "upstream_addr": "$upstream_addr"
              }
            ''
          }';
          access_log ${cfg.settings.collectors.nginx.logPath} logger-json;
        '';

  };
}
