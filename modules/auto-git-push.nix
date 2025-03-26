{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.meta.services.auto-push-git;
in
{
  options.meta.services.auto-push-git = lib.options.mkOption {
    description = ''
      A directory to watch and automatically push.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            enable = lib.options.mkEnableOption "Enable watching the given directory";
            directory = lib.options.mkOption {
              type = lib.types.path;
              description = "The path to automatically push";
            };
            onDate = lib.options.mkOption {
              type = lib.types.singleLineStr;
              default = "hourly";
              example = "weekly";
              description = ''
                How often to attempt pushing changes in the given directory.

                Must be in a {manpage}`systemd.time(7)` format.
              '';
            };
            script = lib.options.mkOption {
              type = lib.types.string;
              default = "${
                pkgs.writeShellApplication {
                  name = "auto-push-git";
                  runtimeInputs = with pkgs; [
                    git
                  ];
                  text = ''
                    #!${pkgs.bash}/bin/bash
                    set -eEuo pipefail
                    git add .
                    git commit -m "Auto Push"
                    git push
                  '';
                }
              }/bin/auto-push-git";
            };
          };
        }
      )
    );
  };
  config =
    let
      enabledDirs = lib.attrsets.filterAttrs (_: config: config.enable) cfg.auto-push-git;
      mkSvcDirName = path: "auto-push-git-${path}";
      eachEnabledDir =
        f:
        lib.attrsets.mapAttrs' (
          name: config: lib.attrsets.nameValuePair (mkSvcDirName name) (f name config)
        ) enabledDirs;
    in
    {
      systemd = {
        services = eachEnabledDir (
          name: config: {
            description = "Auto Push Git Directory: ${name}";
            script = config.script;
            serviceConfig.Type = "oneshot";
            startAt = config.dates;
          }
        );
        timers = eachEnabledDir (
          name: config: {
          }
        );
      };
    };
}
