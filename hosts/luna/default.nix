{ clib, ... }:
{
  imports = (
    clib.recurseFilesInDirs [
      ./os
      ./modules
    ] ".nix"
  );
  system.stateVersion = "25.11";
}