{ inputs, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixVersions.git;
    optimize-nix-store = {
      enable = true;
      randomizedDelaySec = "30min";
    };
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings = {
      experimental-features = [
        "pipe-operators"
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
      trusted-users = [ "@wheel" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}