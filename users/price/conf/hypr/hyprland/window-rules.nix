{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:class ^(xwaylandvideobridge)$, opacity 0.0 override"
      "match:class ^(xwaylandvideobridge)$, no_anim on"
      "match:class ^(xwaylandvideobridge)$, no_initial_focus on"
      "match:class ^(xwaylandvideobridge)$, max_size 1 1"
      "match:class ^(xwaylandvideobridge)$, no_blur on"
    ];
  };
}
