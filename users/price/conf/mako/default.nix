{ pkgs, clib, ... }:
let

  colors = clib.kcolors;
  hx = colors.hex;
in
{
  home.packages = with pkgs; [
    mako
  ];

  services.mako = {
    enable = true;
    settings = {
      font = "Fira Code 12";
      background-color = "#${hx.sumiInk0}";
      border-color = "#${hx.roninYellow}";
      border-radius = 10;
      max-history = 500;
      text-color = "#${hx.autumnYellow}";
      progress-color = "over #${hx.crystalBlue}";
      default-timeout = 8000;
      width = 500;
      height = 150;
      on-touch = "none";
      format = ''<b><span size="larger" fgcolor="#${hx.crystalBlue}">%s</span></b>\n%b\n<span size="small" fgcolor="#${hx.sumiInk6}">%a</span>'';

      "urgency=critical" = {
        background-color = "#${hx.peachRed}";
        default-timeout = 0;
        ignore-timeout = 1;
        border-color = "#${hx.peachRed}";
        text-color = "#${hx.sumiInk2}";
        format = ''<b><span size="larger" fgcolor="#${hx.sumiInk0}">%s</span></b>\n%b\n<span size="small" fgcolor="#${hx.sumiInk6}">%a</span>'';
      };

      "app-name=tidal-hifi" = {
        border-color = "#${hx.surimiOrange}";
        text-color = "#${hx.surimiOrange}";
        format = ''<b><span size="larger" fgcolor="#${hx.surimiOrange}">%s</span></b>\n%b\n<span size="small" fgcolor="#${hx.sumiInk6}">%a</span>'';
      };

      "app-name=orgmode" = {
        background-color = "#${hx.carpYellow}";
        default-timeout = 0;
        ignore-timeout = 1;
        border-color = "#${hx.carpYellow}";
        text-color = "#${hx.sumiInk2}";
        format = ''<b><span size="larger" fgcolor="#${hx.sumiInk0}">%s</span></b>\n%b\n<span size="small" fgcolor="#${hx.sumiInk6}">%a</span>'';
      };

      "app-name=Thunderbird" = {
        background-color = "#${hx.crystalBlue}";
        default-timeout = 0;
        ignore-timeout = 1;
        border-color = "#${hx.crystalBlue}";
        text-color = "#${hx.sumiInk2}";
        format = ''<b><span size="larger" fgcolor="#${hx.sumiInk0}">%s</span></b>\n%b\n<span size="small" fgcolor="#${hx.sumiInk6}">%a</span>'';
      };
    };
  };
}
