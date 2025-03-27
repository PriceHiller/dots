{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    theme = ./themes/kanagawa.rasi;
    extraConfig = {
      matching = "fuzzy";
      drun-match-fields = "name";
    };
    package = pkgs.rofi-wayland;
  };
}
