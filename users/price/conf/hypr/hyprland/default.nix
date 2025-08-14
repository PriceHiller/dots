{
  inputs,
  pkgs,
  clib,
  ...
}:
let
  colors = clib.kcolors;
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
    ];
    settings = {
      plugin = {
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
