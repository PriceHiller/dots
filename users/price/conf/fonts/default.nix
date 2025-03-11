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
    twemoji-color-font
    vistafonts
    roboto
  ];
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Noto Sans"
          "Symbols Nerd Font"
        ];
        serif = [
          "Noto Serif"
          "Symbols Nerd Font"
        ];
        monospace = [
          "FiraCode Nerd Font"
          "Noto Sans Mono"
          "Symbols Nerd Font Mono"
        ];
        emoji = [
          "Twitter Color Emoji"
          "Noto Color Emoji"
          "Symbols Nerd Font Mono"
        ];
      };
    };
  };
}
