{
  description = "Flake for the Kanagwa GTK Theme";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    kanagawa-gtk = {
      flake = false;
      url = "github:Fausto-Korpsvart/Kanagawa-GKT-Theme";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, kanagawa-gtk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
      in rec {
        # This builds the blog binary then runs it and collects the output. Once done it throws away the binary and
        # shoves the newly created static site into the result.
        packages.kanagawa-gtk-theme = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "kanagawa-gtk-theme";
          version = "unknown";

          src = "${kanagawa-gtk}";

          propagatedUserEnvPkgs = with pkgs; [ gtk-engine-murrine ];

          nativeBuildInputs = with pkgs; [ gtk3 ];

          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/themes
            cp -a themes/* $out/share/themes
            runHook postInstall
          '';
          meta = with lib; {
            description =
              "A GTK theme with the Kanagawa colour palette. Borrowed with ❤️ from https://github.com/NixOS/nixpkgs/pull/277073.";
            homepage = "https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme";
            license = licenses.gpl3Only;
            platforms = platforms.all;
          };

        };
        packages.default = packages.kanagawa-gtk-theme;

        packages.kanagwa-icon-theme = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "kanagawa-icon-theme";
          version = "unknown";

          src = "${kanagawa-gtk}";

          nativeBuildInputs = with pkgs; [ gtk3 ];

          propagatedBuildInputs = with pkgs; [ hicolor-icon-theme ];

          dontDropIconThemeCache = true;

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/icons
            cp -a icons/* $out/share/icons
            for theme in $out/share/icons/*; do
              gtk-update-icon-cache -f $theme
            done

            runHook postInstall
          '';

          meta = with lib; {
            description =
              "An icon theme for the Kanagawa colour palette. Borrowed with ❤️ from https://github.com/NixOS/nixpkgs/pull/277073.";
            homepage = "https://github.com/Fausto-Korpsvart/Kanagawa-GKT-Theme";
            license = licenses.gpl3Only;
            platforms = platforms.all;
          };
        };

        # Rust dev environment
      }) // {
        overlays.default = final: prev: {
          kanagawa-gtk-theme = self.packages.${final.system}.kanagawa-gtk-theme;
          kanagawa-gtk-icon-theme = self.packages.${final.system}.kanagwa-icon-theme;
        };
      };
}
