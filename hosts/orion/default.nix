{ pkgs, clib, ... }:
{
  imports = (
    clib.recurseFilesInDirs [
      ./os
      ./modules
    ] ".nix"
  );
  system.stateVersion = "26.05";
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  time.timeZone = "America/Chicago";
}
