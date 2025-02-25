{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    decoration = {
      rounding = 6;
      rounding_power = 4.0;
      blur = {
        enabled = true;
        size = 8;
        passes = 3;
        noise = 0.01;
      };
      shadow.enabled = true;
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
