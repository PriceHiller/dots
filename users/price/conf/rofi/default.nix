{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.rofi-tools.packages.${pkgs.system}.rofi-cliphist
  ];
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
