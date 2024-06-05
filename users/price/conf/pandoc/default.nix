{ pkgs, ... }:
{
  home.packages = with pkgs; [ texliveTeTeX ];
  programs.pandoc = {
    enable = true;
  };
}
