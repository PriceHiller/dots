{
  description = "Flake for custom formatting script";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        # This builds the blog binary then runs it and collects the output. Once done it throws away the binary and
        # shoves the newly created static site into the result.
        packages.default =
          pkgs.writeScriptBin "Fmt" (builtins.readFile ./fmt.bash);

        # Rust dev environment
        devShells.default = pkgs.mkShell;
      }) // {
        overlays.default = final: prev: {
          Fmt = self.packages.${final.system}.default;
        };
      };
}
