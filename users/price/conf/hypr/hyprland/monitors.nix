{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      " ,preferred,auto,auto"
      "eDP-1,preferred,0x0,1.5"
    ];
    exec = [
      "systemd-run --user ${./scripts/laptop-lid.bash}"
    ];
    bindl = [
      ",switch:off:Lid Switch,exec,systemd-run --user ${./scripts/laptop-lid.bash}"
      ",switch:on:Lid Switch,exec,systemd-run --user ${./scripts/laptop-lid.bash}"
    ];
  };
}
