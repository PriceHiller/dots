{ config, ... }:
let
  eDP-1-wallpaper = builtins.toString ../wallpapers/Autumn-Leaves.jpg;
  default-wallpaper = builtins.toString ../wallpapers/Nebula.jpg;
in
{
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
