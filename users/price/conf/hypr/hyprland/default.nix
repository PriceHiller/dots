{
  clib,
  ...
}:
let
  colors = clib.kcolors;
in
{
  # TODO: Migrate to a lua based configuration.
  # Holy shit, Hyprland finally did it!
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
    configType = "hyprlang";
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
    };
  };
}
