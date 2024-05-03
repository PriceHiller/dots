{ lib, ... }:
{
  imports = (
    lib.recurseFilesInDirs [
      ./os
      ./modules
    ] ".nix"
  );
  system.stateVersion = "24.05";
}
