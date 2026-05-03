{ pkgs, ... }:
{

  home.packages = with pkgs; [
    swaynotificationcenter
  ];
  services.swaync = {
    enable = true;
    style = import ./style/package.nix { inherit pkgs; };
  };
}
