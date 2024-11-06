{ ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "pipe-operators"
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "daily";
    };
  };
}