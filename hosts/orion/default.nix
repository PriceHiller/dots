{ pkgs, clib, ... }:
{
  imports = (
    clib.recurseFilesInDirs [
      ./os
      ./modules
    ] ".nix"
  );
  system.stateVersion = "25.11";
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  time.timeZone = "America/Chicago";
}
