{ config, ... }:
let
  laptop-mon = "desc:Samsung Display Corp. 0x414D";
  laptop-mon-options = "preferred,0x0,1.5";
in
{
  wayland.windowManager.hyprland = {
    extraConfig =
      let
        mon-conf-path = "${config.xdg.configHome}/hypr/monitors.conf";
        mon-laptop-conf-path = "${config.xdg.configHome}/hypr/laptop-monitors.conf";
      in
      ''
        exec-once=echo 'monitor = ,preferred,auto,auto' > '${mon-conf-path}'
        source=${mon-conf-path}
        exec-once=echo "" > '${mon-conf-path}'

        exec-once=echo 'monitor = ${laptop-mon},${laptop-mon-options}' > '${mon-laptop-conf-path}'
        source=${mon-laptop-conf-path}
        exec-once=echo "" > '${mon-laptop-conf-path}'
        bindl=,switch:off:Lid Switch,exec,echo "monitor=${laptop-mon},${laptop-mon-options}" > '${mon-laptop-conf-path}'
        bindl=,switch:on:Lid Switch,exec,echo "monitor=eDP-1,disable" > '${mon-laptop-conf-path}'
      '';
  };
}
