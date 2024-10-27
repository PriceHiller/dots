{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fontconfig
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
    fira
    ibm-plex
    open-sans
    noto-fonts
    twitter-color-emoji
    vistafonts
    roboto
  ];
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [
          "Fira Code"
          "Noto Sans Mono"
        ];
        emoji = [
          "Twemoji"
          "Noto Color Emoji"
        ];
      };
    };
  };
}
