{
  inputs,
  pkgs,
  ...
}:
let
  colors = import ../colors.nix;
in
{
  imports = [
    ./appearance.nix
    ./monitors.nix
    ./window-rules.nix
    ./bindings.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    extraConfig = (builtins.readFile ./application/gromit-mpx.conf);
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
      inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
    ];
    settings = {
      plugin = {
        hyprtrails = {
          color = "rgb(${colors.rgb.waveRed})";
          bezier_step = 0.1;
          points_per_step = 10;
          history_step = 1;
        };
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(${colors.hex.sumiInk1})";
          workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1
          skip_empty = true;

          enable_gesture = true; # laptop touchpad
          gesture_fingers = 3; # 3 or 4
          gesture_distance = 300; # how far is the "max"
        };
        dynamic-cursors = {
          enabled = true;
          mode = "stretch";
          stretch = {
            limit = 3000;
            function = "linear";
            window = 50;
          };
          shake = {
            timeout = 500;
            base = 2.0;
            speed = 4.0;
            influence = 1.0;
          };
        };
      };
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "rgb(${colors.hex.surimiOrange}) 45deg";
        "col.inactive_border" = "rgb(${colors.hex.sumiInk4})";
      };
      misc = {
        enable_anr_dialog = false;
        disable_hyprland_logo = true;
        focus_on_activate = true;
        animate_manual_resizes = true;
      };
      dwindle = {
        pseudotile = 0;
      };
      gestures = {
        workspace_swipe = false;
      };
    };
  };
}
