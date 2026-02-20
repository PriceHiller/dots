{ pkgs, ... }:
{
  home.packages = with pkgs; [ texliveFull ];
  programs.pandoc = {
    enable = true;
  };
}
