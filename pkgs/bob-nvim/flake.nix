{
  description = "Flake for bob-nvim, a Neovim version manager.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    bob = {
      flake = false;
      url = "github:MordechaiHadad/bob";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, bob }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rust-toolchain = pkgs.symlinkJoin {
          name = "rust-toolchain";
          paths = with pkgs; [
            rustc
            cargo
            cargo-watch
            rust-analyzer
            rustfmt
          ];
        };
      in
      rec {
        # This builds the blog binary then runs it and collects the output. Once done it throws away the binary and
        # shoves the newly created static site into the result.
        packages.default = pkgs.rustPlatform.buildRustPackage {
          name = "bob-nvim";
          pname = "bob";
          src = "${bob}";
          cargoLock.lockFile = "${bob}/Cargo.lock";
        };

        overlays.default = packages.default;
        # Rust dev environment
        devShells.default = pkgs.mkShell {
          shellHook = ''
            # For rust-analyzer 'hover' tooltips to work.
            export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
          '';
          nativeBuildInputs = [ rust-toolchain ];
        };
      });
}
