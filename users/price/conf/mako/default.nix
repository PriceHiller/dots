{ pkgs, clib, ... }:
let
  colors = clib.kcolors;
  hx = colors.hex;
  mkCard =
    {
      bg,
      title-fg ? "#${hx.sumiInk0}",
      app-fg ? "#${hx.sumiInk6}",
    }:
    {
      background-color = bg;
      border-color = bg;
      text-color = "#${hx.sumiInk2}";
      format = ''<b><span size="larger" fgcolor="${title-fg}">%s</span></b>\n%b\n<span size="small" fgcolor="${app-fg}">%a</span>'';
    };
  mkImportantCard =
    attrs:
    (mkCard attrs)
    // {
      default-timeout = 0;
      ignore-timeout = 1;
    };
in
{
  home.packages = with pkgs; [
    mako
  ];

  services.mako = {
    enable = false;
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

      "urgency=critical" = mkImportantCard {
        bg = "#${hx.peachRed}";
      };

      "app-name=tidal-hifi" = {
        border-color = "#${hx.surimiOrange}";
        text-color = "#${hx.surimiOrange}";
        format = ''<b><span size="larger" fgcolor="#${hx.surimiOrange}">%s</span></b>\n%b\n<span size="small" fgcolor="#${hx.sumiInk6}">%a</span>'';
      };

      "app-name=Thunderbird" = mkImportantCard {
        bg = "#${hx.crystalBlue}";
      };
      "app-name=equibop" = mkImportantCard {
        bg = "#${hx.oniViolet}";
      };
    };
  };
}
