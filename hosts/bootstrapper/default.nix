{
  pkgs,
  clib,
  modulesPath,
  ...
}:
{
  imports =
    (clib.recurseFilesInDirs [
      ./modules
    ] ".nix")
    ++ [
      # This allow the system to produce an ISO
      (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ];

  system.stateVersion = "26.05";
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    nixos-rebuild
    nixos-install-tools
    age
  ];
  time.timeZone = "America/Chicago";
}
