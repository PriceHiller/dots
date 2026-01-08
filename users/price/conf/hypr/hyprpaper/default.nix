{ pkgs, ... }:
let
  # This might seem goofy, but this ensures that the wallpapers aren't garbage collected as this
  # ensures valid store paths exist in `/nix/store`
  wallpapers = pkgs.runCommand "protect-wallpapers-from-gc" { } ''
    mkdir -p $out
    cp ${../wallpapers/Autumn-Leaves.jpg} $out/Autumn-Leaves.jpg
    cp ${../wallpapers/Nebula.jpg} $out/Nebula.jpg
  '';
  eDP-1-wallpaper = "${wallpapers}/Autumn-Leaves.jpg";
  default-wallpaper = "${wallpapers}/Nebula.jpg";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        eDP-1-wallpaper
        default-wallpaper
      ];
      splash = false;
      wallpaper = [
        {
          monitor = "eDP-1";
          path = eDP-1-wallpaper;
        }
        {
          monitor = "";
          path = default-wallpaper;
        }
      ];
    };
  };
}
