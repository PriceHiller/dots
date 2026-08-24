{ clib, pkgs, ... }:
let

  colors = clib.kcolors.hex;
in
{
  home.packages = with pkgs; [
    grim
  ];

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        showAbortNotification = false;
        showStartupLaunchMessage = false;
        # showDesktopNotification = false;
        showHelp = true;
        uiColor = "#${colors.sakuraPink}";
        contrastUiColor = "#${colors.winterRed}";
        drawColor = "#${colors.crystalBlue}";
      };
    };
  };
}
