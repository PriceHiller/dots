{
  config,
  pkgs,
  lib,
  inputs,
  clib,
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
              endpoint = cfg.settings.sinks.loki.endpoint;
              encoding.codec = "json";
              acknowledgements.enabled = true;
              buffer = {
                type = "disk";
                max_size = 512 * (clib.pow 2 20);
                when_full = "block";
              };
              # Every event reaching this sink MUST have `.level` and `%service_name`,
              # otherwise the template fails and the event is dropped.
              labels = {
                service_name = "{{ %service_name }}";
                system_host = config.system.name;
                nixos_state_version = config.system.stateVersion;
                level = "{{ .level }}";
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
              auth = {
                strategy = "basic";
                user = "\${BASIC_AUTH_USERNAME}";
                password = "\${BASIC_AUTH_PASSWORD}";
              };
            };
          };
        };
      }

      # -- Catch-all for events that failed processing --
      (lib.mkIf (journaldCfg.enable || nginxCfg.enable) {
        services.vector.settings.transforms.transform_dropped_sink = {
          inputs =
            lib.optional journaldCfg.enable "transform_journald_sink.dropped"
            ++ lib.optional nginxCfg.enable "transform_nginx.dropped";
          type = "remap";
          source = # vrl
            ''
              . = {
                "level": "error",
                "reason": %vector.dropped,
                "original": .
              }
              %service_name = "vector-dropped"
            '';
        };
      })

      (lib.mkIf journaldCfg.enable {
        systemd.services.vector.serviceConfig.SupplementaryGroups = [ "systemd-journal" ];

        services.vector.settings.sources.source_journald = {
          type = "journald";
        };

        services.vector.settings.transforms.transform_journald_sink = {
          inputs = [ "source_journald" ];
          type = "remap";
          drop_on_error = true;
          reroute_dropped = true;
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

              .level = to_syslog_level(to_int(jmeta.PRIORITY) ?? -1) ?? "unknown"
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

        services.vector.settings.transforms = {
          # NOT suffixed `_sink`: output only reaches Loki via the filter below
          transform_nginx = {
            inputs = [ "source_nginx" ];
            type = "remap";
            drop_on_error = true;
            reroute_dropped = true;
            source = # vrl
              ''
                # Compile-time only; must be unconditional
                set_semantic_meaning(%timestamp, "timestamp")

                syslog = parse_syslog!(string!(.))
                msg = object!(parse_json!(syslog.message))

                # -- Status & level --
                status = to_int(msg.status) ?? 0
                msg.status = status
                msg.level = if status >= 500 { "error" } else if status >= 400 { "warn" } else { "info" }

                # -- Timestamp: $msec is seconds with ms resolution --
                secs, err = to_float(msg.time_unix)
                if err == null {
                  ts, err = from_unix_timestamp(to_int(secs * 1000), unit: "milliseconds")
                  if err == null {
                    %timestamp = ts
                    del(msg.time_unix)
                  }
                }

                # -- Simple conversions --
                msg.pipelined = msg.pipe == "p"
                del(msg.pipe)
                msg.gzip_ratio = to_float(msg.gzip_ratio) ?? null
                msg.tcp = map_values(object(msg.tcp) ?? {}) -> |v| { to_int(v) ?? null }

                # -- Request: nginx fields + parsed URL --
                req = object(msg.request) ?? {}
                url, err = parse_url(
                  (string(req.scheme) ?? "http") + "://" + (string(req.host) ?? "localhost") + (string(req.uri) ?? "")
                )
                if err == null {
                  req = merge(req, url)
                }
                req.completed = req.completion == "OK"
                del(req.completion)
                msg.request = req

                # -- TLS (only for TLS requests, otherwise the booleans would survive compact) --
                if (string(msg.tls.protocol) ?? "") != "" {
                  msg.tls.session_reused = msg.tls.session_reused == "r"
                  msg.tls.early_data = msg.tls.early_data == "1"
                } else {
                  del(msg.tls)
                }

                # -- Upstream --
                ${
                  let
                    # nginx joins values from multiple upstream attempts with ", " (servers in one group)
                    # and " : " (across groups, e.g. internal redirects).
                    upstreamLast = field: conv: ''
                      parts = split(string(${field}) ?? "", r'\s*[,:]\s*')
                      ${field} = ${conv}(parts[-1]) ?? null
                    '';

                    upstreamVrl = lib.concatStrings (
                      lib.mapAttrsToList (field: conv: upstreamLast "up.${field}" conv) {
                        status = "to_int";
                        connect_time = "to_float";
                        header_time = "to_float";
                        queue_time = "to_float";
                        "response.time" = "to_float";
                        "response.length" = "to_int";
                        "bytes.sent" = "to_int";
                        "bytes.received" = "to_int";
                      }
                    );
                  in
                  # vrl
                  ''
                    up = object(msg.upstream) ?? {}
                    ${upstreamVrl}
                    msg.upstream = up
                  ''
                }

                # -- Referer (must come after request, uses request.host) --
                ref = string(msg.headers.request.referer) ?? ""
                if ref != "" {
                  r, err = parse_url(ref)
                  if err == null {
                    r.external = r.host != msg.request.host
                    msg.referer = r
                  }
                }

                # -- User agent --
                ua = string(msg.headers.request."user-agent") ?? ""
                if ua != "" {
                  msg.user_agent = parse_user_agent(ua, mode: "enriched")
                  msg.user_agent.raw = ua
                }

                # Must stay last: strips "", null, {} and []
                . = compact(msg)
                %service_name = "nginx"
              '';
          };

          filter_nginx_sink = {
            inputs = [ "transform_nginx" ];
            type = "filter";
            # Drop successful Vector to Loki pushes (feedback loop), keep failures
            condition = ''!(.request.path == "/loki/api/v1/push" && .status == 204)'';
          };
        };

        # Error log via syslog so journald can get the actual severities
        services.nginx.logError = lib.mkDefault "syslog:server=unix:/dev/log warn";

        services.nginx.commonHttpConfig =
          let
            nginxJson = rec {
              # Emit the variable unquoted. Only use for variables that are ALWAYS numeric.
              raw = value: {
                _type = "nginx-raw";
                inherit value;
              };

              # [ "user-agent" ] -> { "user-agent" = "$http_user_agent"; }
              headers =
                prefix: names:
                lib.genAttrs names (name: prefix + builtins.replaceStrings [ "-" ] [ "_" ] (lib.toLower name));

              toJSON =
                v:
                if lib.isAttrs v && (v._type or null) == "nginx-raw" then
                  v.value
                else if lib.isAttrs v then
                  "{"
                  + lib.concatStringsSep "," (lib.mapAttrsToList (k: x: "${builtins.toJSON k}:${toJSON x}") v)
                  + "}"
                else if lib.isString v then
                  builtins.toJSON v
                else
                  throw "nginxJson: unsupported value type ${builtins.typeOf v}";

              # nginx unescapes \\ and \' inside quoted strings
              logFormat =
                name: attrs: "log_format ${name} escape=json '${lib.escape [ "\\" "'" ] (toJSON attrs)}';";
            };
          in
          # nginx
          ''
            ${nginxJson.logFormat "vector-logger-json" (
              let
                inherit (nginxJson) raw headers;
              in
              {
                time_unix = raw "$msec";
                status = raw "$status";
                pid = raw "$pid";
                nginx_version = "$nginx_version";
                pipe = "$pipe";
                gzip_ratio = "$gzip_ratio";
                bytes_sent = raw "$bytes_sent";
                body_bytes_sent = raw "$body_bytes_sent";

                request = {
                  id = "$request_id";
                  method = "$request_method";
                  uri = "$request_uri";
                  line = "$request";
                  length = raw "$request_length";
                  time = raw "$request_time";
                  completion = "$request_completion";
                  scheme = "$scheme";
                  host = "$host";
                };

                remote = {
                  addr = "$remote_addr";
                  port = raw "$remote_port";
                  user = "$remote_user";
                };

                server = {
                  name = "$server_name";
                  addr = "$server_addr";
                  port = raw "$server_port";
                  protocol = "$server_protocol";
                };

                connection = {
                  serial = raw "$connection";
                  requests = raw "$connection_requests";
                  time = raw "$connection_time";
                };

                limit = {
                  req_status = "$limit_req_status";
                  conn_status = "$limit_conn_status";
                };

                tcp = {
                  rtt = raw "$tcpinfo_rtt";
                  rttvar = raw "$tcpinfo_rttvar";
                  snd_cwnd = raw "$tcpinfo_snd_cwnd";
                  rcv_space = raw "$tcpinfo_rcv_space";
                };

                tls = {
                  protocol = "$ssl_protocol";
                  cipher = "$ssl_cipher";
                  server_name = "$ssl_server_name";
                  alpn = "$ssl_alpn_protocol";
                  curve = "$ssl_curve";
                  session_reused = "$ssl_session_reused";
                  early_data = "$ssl_early_data";
                  client = {
                    ciphers = "$ssl_ciphers";
                    curves = "$ssl_curves";
                  };
                };

                upstream = {
                  addr = "$upstream_addr";
                  status = "$upstream_status";
                  cache_status = "$upstream_cache_status";
                  connect_time = "$upstream_connect_time";
                  header_time = "$upstream_header_time";
                  response = {
                    time = "$upstream_response_time";
                    length = "$upstream_response_length";
                  };
                  bytes = {
                    sent = "$upstream_bytes_sent";
                    received = "$upstream_bytes_received";
                  };
                };

                headers = {
                  request = headers "$http_" [
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
                  ];
                  response = headers "$sent_http_" [
                    "content-type"
                    "content-encoding"
                    "etag"
                    "cache-control"
                    "vary"
                    "location"
                  ];
                };
              }
            )}

            access_log syslog:server=unix:${nginxCfg.logSocketPath} vector-logger-json;
          '';
      })

    ]
  );
}
