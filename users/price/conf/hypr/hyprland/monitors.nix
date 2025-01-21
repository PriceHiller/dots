{ pkgs, ... }:
let
  laptop-mon = "desc:Samsung Display Corp. 0x414D";
  laptop-mon-options = "preferred,0x0,1.5";
  laptop-lid-script = ''systemd-run --unit=laptop-lid --user ${./scripts/laptop-lid.bash} "${laptop-mon}" "${laptop-mon-options}"'';
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      " ,preferred,auto,auto"
      "${laptop-mon},${laptop-mon-options}"
    ];
    exec = [
      "${pkgs.coreutils}/bin/sleep 3 && ${laptop-lid-script}"
    ];
    bindl = [
      ",switch:off:Lid Switch,exec,${laptop-lid-script}"
      ",switch:on:Lid Switch,exec,${laptop-lid-script}"
    ];
  };
}
