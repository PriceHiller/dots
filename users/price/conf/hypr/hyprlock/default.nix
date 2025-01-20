{ pkgs, ... }:
let
  colors = import ../colors.nix;
in
{
  home.packages = with pkgs; [
    overpass
  ];
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        ignore_empty_input = true;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "${../../../wallpapers/Autumn-Leaves.jpg}";
          blur_passes = 3;
          blur_size = 5;
        }
      ];

      input-field = [
        {
          size = "150, 50";
          outline_thickness = 2;
          dots_size = 0.2;
          position = "0, -75";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(${colors.rgb.fujiWhite})";
          outer_color = "rgba(0, 0, 0, 0.0)";
          inner_color = "rgba(0, 0, 0, 0.4)";
          check_color = "rgba(${colors.hex.springViolet1}ff) rgba(${colors.hex.springViolet2}ff) 120deg";
          fail_color = "rgba(${colors.hex.peachRed}ff) rgba(${colors.hex.waveRed}ff) 40deg";
          placeholder_text = ''<i><span foreground="##${colors.hex.fujiGray}">Input Password...</span></i>'';
        }
      ];
      label = [
        # Battery capacity
        {
          text = ''cmd[update:1000] ${./scripts/battery-level.bash}'';
          font_size = 10;
          font_color = "rgb(${colors.rgb.fujiWhite})";
          position = "10, 10";
          halign = "left";
          valign = "bottom";
          shadow_color = "rgba(0, 0, 0, 0.20)";
          shadow_passes = 3;
          shadow_size = 2;
        }
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%-I:%M%p")"'';
          color = "rgb(${colors.rgb.autumnYellow})";
          font_size = 120;
          font_family = "Overpass ExtraBold";
          position = "0, 100";
          halign = "center";
          valign = "center";
          shadow_color = "rgba(0, 0, 0, 0.30)";
          shadow_passes = 3;
          shadow_size = 2;
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
          color = "rgb(${colors.rgb.autumnYellow})";
          font_size = 25;
          font_family = "Overpass SemiBold";
          position = "0, 0";
          halign = "center";
          valign = "center";
          shadow_color = "rgba(0, 0, 0, 0.30)";
          shadow_passes = 3;
          shadow_size = 2;
        }
      ];
    };
  };
}
