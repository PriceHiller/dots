{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.ext.services.alloy;
in
{
  options.ext.services.alloy = {
    enable = lib.mkEnableOption "Enable Grafana Alloy with some default options applied";
    enableDefaultConfig = lib.mkEnableOption "Inserts some default config to export a few sources";
    loki = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "loki.pricehiller.com";
        description = "The host at which the loki server resides";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 443;
        description = "The port loki is listening on";
      };
      address = lib.mkOption {
        type = lib.types.str;
        default = "${cfg.loki.host}:${builtins.toString cfg.loki.port}";
        readOnly = true;
        description = "The effective address for the loki instance, just 'host:port'";
      };
      protocol = lib.mkOption {
        type = lib.types.enum [
          "https"
          "http"
        ];
        default = "https";
        description = "The protocol to used to connect to loki";
      };
      path = lib.mkOption {
        type = lib.types.str;
        default = "loki/api/v1/push";
        description = "The path to the loki push endpoint";
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = ''"${cfg.loki.protocol}://${cfg.loki.address}/${cfg.loki.path}"'';
        readOnly = true;
        description = "The full path to the push url on the loki instance";
      };
    };
    endpointName = lib.mkOption {
      type = lib.types.str;
      default = "endpoint";
      description = "The default loki writer endpoint name";
    };

    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "loki.write.${cfg.endpointName}.receiver";
      readOnly = true;
      description = "The default loki writer for use in Alloy configuration";
    };

    extraConfig = lib.mkOption {
      type = lib.types.listOf (lib.types.lines);
      default = [ ];
      description = "Additional alloy configuration to add";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      example = "/run/secrets/alloy.env";
      default = null;
      description = ''
        EnvironmentFile as defined in `systemd.exec(5)`.

        The file should contain two values like so for basic authentication:
        BASIC_AUTH_USERNAME=some_username
        BASIC_AUTH_PASSWORD=some_password
      '';
    };
  };

  config = lib.mkIf (cfg.enable) {
    services.alloy = {
      enable = true;
      extraFlags = [
        "--disable-reporting"
      ];
      environmentFile = cfg.environmentFile;
    };

    systemd.services.alloy.serviceConfig.SupplementaryGroups = lib.mkIf (cfg.enableDefaultConfig) [
      "adm"
    ];

    environment.etc = {
      "alloy/extra.alloy" = lib.mkIf ((builtins.length cfg.extraConfig) > 0) {
        text = lib.mkMerge cfg.extraConfig;
      };
      "alloy/config.alloy".text =
        let
          endpoint = cfg.endpoint;
        in
        lib.mkMerge [
          # Setup the loki server endpoint
          ''
            loki.write "${cfg.endpointName}" {
              external_labels = {
                nixos_host = "${config.system.name}",
                nixos_system_rev = "${
                  let
                    self = inputs.self;
                    rev =
                      self.rev or self.dirtyRev or self.lastModified or config.system.configurationRevision
                        or "unknown";
                  in
                  rev
                }",
                nixos_state_verison = "${config.system.stateVersion}",
              }

              endpoint {
                url = ${cfg.loki.url}

                ${lib.optionalString (cfg.environmentFile != null) ''
                  basic_auth {
                    username = sys.env("BASIC_AUTH_USERNAME")
                    password = sys.env("BASIC_AUTH_PASSWORD")
                  }
                ''}
              }
            }
          ''
          (lib.optionalString (cfg.enableDefaultConfig)
            # Read all lines from the Journal (Journald)
            ''
              loki.relabel "journal" {
                forward_to = []
                rule {
                  source_labels = ["__journal__systemd_unit"]
                  target_label  = "unit"
                }

                rule {
                  source_labels = ["__journal__syslog_identifier"]
                  target_label = "syslog_identifier"
                }

                rule {
                  source_labels = ["__journal__machine_id"]
                  target_label = "machine_id"
                }

                rule {
                  source_labels = ["__journal__transport"]
                  target_label  = "transport"
                }

                rule {
                  source_labels = ["__journal_priority_keyword"]
                  target_label  = "level"
                }

                rule {
                  source_labels = ["__journal__boot_id"]
                  target_label = "boot_id"
                }
              }

              loki.source.journal "read"  {
                forward_to    = [${endpoint}]
                labels        = { service_name = "loki.source.journal.${config.networking.hostName}" }
                relabel_rules = loki.relabel.journal.rules
              }
            ''
          )
        ];
    };
  };
}
