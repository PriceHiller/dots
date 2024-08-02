{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fontconfig
    nerdfonts
    fira-code
    noto-fonts
    twitter-color-emoji
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
