{
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
    ./plugins.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = (builtins.readFile ./application/gromit-mpx.conf);
    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;
        "col.active_border" = "rgb(${colors.hex.surimiOrange}) 45deg";
        "col.inactive_border" = "rgb(${colors.hex.sumiInk4})";
      };
      misc = {
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
