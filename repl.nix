let
  flake = builtins.getFlake (toString ./.);
  pkgs = import flake.inputs.nixpkgs { };
  lib = pkgs.lib;
in
flake
// {
  nc = flake.nixosConfigurations;
  inherit pkgs;
  inherit lib;
}
