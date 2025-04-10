{
  config,
  lib,
  ...
}:
let
  cfg = config.nix.optimize-nix-store;
in
{
  options.nix.optimize-nix-store = {
    enable = lib.mkEnableOption "Auto optimize the nix store on a schedule.";

    dates = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "daily";
      example = "weekly";
      description = ''
        How often or when nix store optimization is performed.

        This value must be a calendar event in the format specified by
        {manpage}`systemd.time(7)`.
      '';
    };

    randomizedDelaySec = lib.mkOption {
      default = "0";
      type = lib.types.singleLineStr;
      example = "45min";
      description = ''
        Add a randomized delay before each nix store optimization.
        The delay will be chosen between zero and this value.
        This value must be a time span in the format specified by
        {manpage}`systemd.time(7)`
      '';
    };

    persistent = lib.mkOption {
      default = true;
      type = lib.types.bool;
      example = false;
      description = ''
        Takes a boolean argument. If true, the time when the service
        unit was last triggered is stored on disk. When the timer is
        activated, the service unit is triggered immediately if it
        would have been triggered at least once during the time when
        the timer was inactive. Such triggering is nonetheless
        subject to the delay imposed by RandomizedDelaySec=. This is
        useful to catch up on missed runs of the service when the
        system was powered down.
      '';
    };
  };
  config = lib.mkIf (cfg.enable && config.nix.enable) {
    systemd = {
      services.optimize-nix-store = {
        description = "Optimizes the Nix Store on a regular schedule";
        script = "exec ${config.nix.package.out}/bin/nix-store --optimise";
        serviceConfig.Type = "oneshot";
        startAt = cfg.dates;
      };
      timers.optimize-nix-store.timerConfig = {
        Persistent = cfg.persistent;
        RandomizedDelaySec = cfg.randomizedDelaySec;
      };
    };
  };
}
