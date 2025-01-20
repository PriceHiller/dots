{
  pkgs,
  ...
}:
let
  colors = import ../colors.nix;
in
{

  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      hyprtrails
      hypr-dynamic-cursors
    ];
    settings = {
      plugin = {
        hyprtrails = {
          color = "rgb(${colors.rgb.springViolet1})";
          bezier_step = 0.1;
          points_per_step = 10;
          history_step = 1;
        };
        dynamic-cursors = {
          enabled = true;
          mode = "stretch";
          stretch = {
            limit = 9000;
          };
          shake = {
            timeout = 500;
            base = 2.0;
            speed = 2.0;
            influence = 1.0;
          };
        };
      };
    };
  };
}
