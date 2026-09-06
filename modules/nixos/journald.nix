{ config, lib, ... }:

let
  cfg = config.ext.journald;

  settingsType = lib.types.oneOf [
    lib.types.str
    lib.types.int
    lib.types.bool
  ];
in
{
  options.ext.journald = {
    enable = lib.options.mkEnableOption "Enable extended Journald configuration";

    settings = lib.options.mkOption {
      description = ''
        Structured journald.conf settings. Arbitrary key-value pairs are
        accepted. Options set to `null` are omitted.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf (lib.types.nullOr settingsType);

        options = {
          SystemMaxUse = lib.options.mkOption {
            type = settingsType;
            default = "50G";
            description = "Maximum disk space for persistent journal files.";
          };

          MaxRetentionSec = lib.options.mkOption {
            type = settingsType;
            default = "30d";
            description = "Maximum time to store journal entries.";
          };
        };
      };
    };
  };

  config = lib.modules.mkIf (cfg.enable) {
    services.journald.settings.Journal = cfg.settings;
  };
}
