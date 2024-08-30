{ pkgs, ... }:
{
  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      use-xdg-base-directories = true;
      trusted-users = [ "@wheel" ];
    };
  };
}
