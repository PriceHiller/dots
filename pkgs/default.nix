{
  pkgs ? (import <nixpkgs> { }),
  # NOTE: If this is called from an overlay then you cannot provide the `final` for
  # `lib`. This has to come from `prev` otherwise the overlay will recursively try to determine the
  # keys of `pkgs.lib` from `final.lib` over and over leading to a infinite recursion
  lib ? pkgs.lib,
  ...
}:
(lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = ./pkgs;
})
// {
  bwrapped = import ./bwrapped { inherit pkgs lib; };
}
