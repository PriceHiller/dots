{ ... }:
{
  services.hyprpaper =
    let
      eDP-1-wallpaper = builtins.toString ../wallpapers/Nebula.jpg;
      default-wallpaper = builtins.toString ../wallpapers/Nebula.jpg;
    in
    {
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
