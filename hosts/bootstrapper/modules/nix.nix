{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixVersions.latest;
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    settings = {
      experimental-features = [
        "pipe-operators"
        "nix-command"
        "flakes"
        "ca-derivations"
        "recursive-nix"
        "dynamic-derivations"
      ];
      trusted-users = [ "@wheel" ];
      log-lines = 100;
      max-jobs = "auto";
    };
  };
}
