{
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
    ./dynamic-cursors.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    extraConfig = (builtins.readFile ./application/gromit-mpx.conf);
    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "rgb(${colors.hex.surimiOrange}) 45deg";
        "col.inactive_border" = "rgb(${colors.hex.sumiInk6})";
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
    };
  };
}
