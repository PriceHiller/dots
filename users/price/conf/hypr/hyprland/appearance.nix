{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    decoration = {
      rounding = 10;
      blur = {
        enabled = true;
        size = 12;
        passes = 6;
        new_optimizations = true;
      };
      shadow = {
        enabled = true;
        range = 4;
        ignore_window = true;
        render_power = 2;
      };
      dim_special = 0.05;
    };

    animations = {
      enabled = 1;
      bezier = [
        "overshot,0.08,0.8,0,1.1"
        "quick_curve,0,.5,0,.5"
      ];
      animation = [
        "windows,1,3,overshot,slide"
        "border,1,3,default"
        "fade,1,3,default"
        "workspaces,1,4,default"
      ];
      # animation = specialWorkspace,0;
    };
  };
}
