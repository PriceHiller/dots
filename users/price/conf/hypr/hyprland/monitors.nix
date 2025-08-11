{ config, ... }:
let
  laptop-mon = "desc:Samsung Display Corp. 0x414D";
  laptop-mon-options = "preferred,0x0,1.5";
  mon-laptop-conf-path = "${config.xdg.configHome}/hypr/laptop-monitors.conf";
  laptop-lid-script = ''LAPTOP_LID_CFG_FILE='${mon-laptop-conf-path}' systemd-run  --unit=laptop-lid --user ${./scripts/laptop-lid.bash} "${laptop-mon}" "${laptop-mon-options}"'';
in
{
  wayland.windowManager.hyprland = {
    extraConfig = ''
      source=${mon-laptop-conf-path}
    '';
    settings = {
      exec = [
        laptop-lid-script
      ];
      monitor = [
        ",preferred,auto,auto"
      ];
      bindl = [
        ",switch:off:Lid Switch,exec,${laptop-lid-script}"
        ",switch:on:Lid Switch,exec,${laptop-lid-script}"
      ];
    };
  };
}
