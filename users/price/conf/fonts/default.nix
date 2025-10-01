{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fontconfig
    overpass
    nerd-fonts.overpass
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    fira-code
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
        sansSerif = [
          "Noto Sans"
          "Twitter Color Emoji"
          "Symbols Nerd Font"
        ];
        serif = [
          "Noto Serif"
          "Twitter Color Emoji"
          "Symbols Nerd Font"
        ];
        monospace = [
          "FiraCode Nerd Font"
          "Noto Sans Mono"
          "Twitter Color Emoji"
          "Symbols Nerd Font Mono"
        ];
        emoji = [
          "Twitter Color Emoji"
          "Symbols Nerd Font"
        ];
      };
    };
  };
}
