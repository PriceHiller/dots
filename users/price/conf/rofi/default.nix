{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.rofi-tools.packages.${pkgs.stdenv.hostPlatform.system}.rofi-cliphist
  ];
  programs.rofi = {
    enable = true;
    theme = ./themes/kanagawa.rasi;
    settings = {
      matching = "fuzzy";
      sorting-method = "fzf";
      drun-match-fields = "name";
    };
  };
}
