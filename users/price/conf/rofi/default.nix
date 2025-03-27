{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    theme = ./themes/kanagawa.rasi;
    extraConfig = {
      matching = "fuzzy";
      sorting-method = "fzf";
      drun-match-fields = "name";
    };
    package = pkgs.rofi-wayland;
  };
}
