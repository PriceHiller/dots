{
  description = "Flake for deepfilternet, a noise supression algorithm.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    deepfilternet-src = {
      flake = false;
      url =
        "github:Rikorose/DeepFilterNet?rev=978576aa8400552a4ce9730838c635aa30db5e61";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, deepfilternet-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        lib = nixpkgs.lib;
        pkgs = nixpkgs.legacyPackages.${system};
        rust-toolchain = pkgs.symlinkJoin {
          name = "rust-toolchain";
          paths = with pkgs; [ rustc cargo ];
        };
      in rec {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = "deepfilternet";
          version = "0.5.6";
          src = "${deepfilternet-src}";
          cargoLock = {
            lockFile = "${deepfilternet-src}/Cargo.lock";
            allowBuiltinFetchGit = true;
          };
          buildInputs = with pkgs; [ ladspaH ];
          buildAndTestSubdir = "ladspa";
          postInstall = ''
            mkdir $out/lib/ladspa
            mv $out/lib/libdeep_filter_ladspa.so $out/lib/ladspa/libdeep_filter_ladspa.so
          '';
          meta = {
            description = "Noise supression using deep filtering";
            homepage = "https://github.com/Rikorose/DeepFilterNet";
            license = with lib.licenses; [ mit asl20 ];
            changelog =
              "https://github.com/Rikorose/DeepFilterNet/releases/tag/${src.rev}";
          };
        };
      }) // {
        overlays.default = final: prev: {
          deepfilternet = self.packages.${final.system}.default;
          easyeffects = let
            pkgs = final.pkgs;
            lib = pkgs.lib;
          in prev.easyeffects.overrideAttrs (oldAttrs: {
            buildInputs = with pkgs; [ deepfilternet ] ++ oldAttrs.buildInputs;
            preFixup = let
              lv2Plugins = with pkgs; [
                calf # compressor exciter, bass enhancer and others
                lsp-plugins # delay, limiter, multiband compressor
                mda_lv2 # loudness
                zam-plugins # maximizer
              ];
              ladspaPlugins = with pkgs; [
                deepfilternet
                rubberband # pitch shifting
              ];
            in ''
              gappsWrapperArgs+=(
                --set LV2_PATH "${lib.makeSearchPath "lib/lv2" lv2Plugins}"
                --set LADSPA_PATH "${
                  lib.makeSearchPath "lib/ladspa" ladspaPlugins
                }"
              )
            '';
          });
        };

      };
}
