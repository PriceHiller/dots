{
  inputs,
  pkgs,
  clib,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixVersions.git;
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
    settings = {
      # Make the download buffer 256 mb
      download-buffer-size = 256 * (clib.pow 2 20);
      # Allow more connections in parallel to fetch files
      http-connections = 50;
      # If a nix build fails, we want to hang onto its build directory for debugging
      keep-failed = true;
      auto-optimise-store = true;
      experimental-features = [
        "pipe-operators"
        "nix-command"
        "flakes"
        "ca-derivations"
        "recursive-nix"
        "dynamic-derivations"
      ];
      use-xdg-base-directories = true;
      trusted-users = [ "@wheel" ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      log-lines = 100;
      max-jobs = "auto";
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
