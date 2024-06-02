{ pkgs, lib, ... }:
{
  imports = (
    lib.recurseFilesInDirs [
      ./os
      ./modules
    ] ".nix"
  );
  system.stateVersion = "24.05";
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  time.timeZone = "America/Chicago";
}
