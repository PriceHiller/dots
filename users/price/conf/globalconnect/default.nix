{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gpclient
    gpauth
  ];
}
