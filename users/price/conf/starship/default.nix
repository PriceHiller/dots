{ config, pkgs, ... }:
{
  home = {
    packages = [ pkgs.starship ];
    sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
  };
}
