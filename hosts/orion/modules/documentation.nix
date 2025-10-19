{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];
  documentation = {
    enable = true;
    dev.enable = true;
    nixos.includeAllModules = true;
  };
}