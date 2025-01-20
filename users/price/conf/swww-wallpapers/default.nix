{ pkgs, ... }:
let
  wallpapers = ../../wallpapers;
in
{
  home.packages = [ pkgs.swww ];
  systemd.user = {
    services = {
      swww-daemon = {
        Service =
          let
            cleanup-socket-script = pkgs.writeShellScript "swww-daemon-cleanup-socket" ''
              # Remove the existing swww.socket if it exists, avoids some issues with swww-daemon
              # startup where swww-daemon claims the address is already in use
              if [[ -w "$XDG_RUNTIME_DIR/swww.socket" ]]; then
                rm -f $XDG_RUNTIME_DIR/swww.socket || exit 1
              fi
            '';
          in
          {
            RestartSec = 3;
            PassEnvironment = [ "XDG_RUNTIME_DIR" ];
            ExecStartPre = "${cleanup-socket-script}";
            ExecStopPost = "${cleanup-socket-script}";
            ExecStart = "${pkgs.swww}/bin/swww-daemon";
          };
        Install.WantedBy = [
          "graphical-session.target"
          "compositor.target"
        ];
        Unit = {
          Description = "Wayland Wallpaper Service";
          PartOf = [
            "graphical-session.target"
            "compositor.target"
          ];
          After = [ "graphical-session.target" ];
        };
      };
      swww-watch-wallpapers = {
        Service = {
          RestartSec = 3;
          Environment = [
            "SWWW_TRANSITION_FPS=120"
            "SWWW_TRANSITION_STEP=30"
            "SWWW_TRANSITION_DURATION=0.75"
          ];
          ExecStart = "${
            pkgs.writeShellApplication {
              name = "swww-watch-wallpapers";
              runtimeInputs = with pkgs; [
                swww
                coreutils
              ];
              text = ''
                set -eEuo pipefail

                main() {
                  local prev_mons_connected=0
                  local mons_connected=0
                  local cached_swww_query

                  while sleep 1; do
                    cached_swww_query="$(swww query)"
                    mons_connected="$(wc -l <<< "$cached_swww_query")"
                    if ((mons_connected != prev_mons_connected)); then
                      prev_mons_connected="$mons_connected"
                      swww img -t random ${wallpapers}/Nebula.jpg
                      if [[ "$cached_swww_query" =~ "eDP-1: "* ]]; then
                        swww img -t wipe --transition-angle 40 -o eDP-1 ${wallpapers}/Autumn-Leaves.jpg
                      fi
                    fi
                  done
                }

                main
              '';
            }
          }/bin/swww-watch-wallpapers";
        };
        Install.WantedBy = [ "swww-daemon.service" ];
        Unit = {
          Description = "Wayland Wallpaper Service";
          PartOf = [ "swww-daemon.service" ];
          After = [ "swww-daemon.service" ];
        };
      };
    };
  };
}
