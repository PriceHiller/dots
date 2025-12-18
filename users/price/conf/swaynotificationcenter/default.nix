{ pkgs, ... }:
{

  home.packages = with pkgs; [
    swaynotificationcenter
  ];
  services.swaync = {
    enable = true;
  };
}
