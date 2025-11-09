let
  flake = builtins.getFlake (toString ./.);
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
in
flake
// {
  nc = flake.nixosConfigurations;
  inherit lib;
}
