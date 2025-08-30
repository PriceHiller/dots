{ config, ... }:
let
  wpapers-dir = "${config.xdg.dataHome}/wallpapers/";
  eDP-1-wallpaper = "${wpapers-dir}/edp1.jpg";
  default-wallpaper = "${wpapers-dir}/default.jpg";
in
{
  link = {
    "${eDP-1-wallpaper}".source = builtins.toString ../wallpapers/Autumn-Leaves.jpg;
    "${default-wallpaper}".source = builtins.toString ../wallpapers/Nebula.jpg;
  };
  systemd.user.services.hyperpaper.Unit.After = [
    config.wayland.systemd.target
    "hm-link-files.target"
  ];
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        eDP-1-wallpaper
        default-wallpaper
      ];
      wallpaper = [
        "eDP-1,${eDP-1-wallpaper}"
        ",${default-wallpaper}"
      ];
    };
  };
}
