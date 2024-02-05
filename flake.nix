{
  description = "Price Hiller's home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    bob = {
      url = "path:./pkgs/bob-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deepfilternet = {
      url = "path:./pkgs/deepfilternet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      username = "sam";
      lib = nixpkgs.lib;
    in {
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      targets.genericLinux.enable = true;
      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ({
              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlay
                inputs.emacs-overlay.overlays.emacs
                inputs.bob.overlays.default
                inputs.deepfilternet.overlays.default
                (final: prev:
                {
                  kanagawa-gtk-theme = prev.callPackage ./pkgs/kanagawa-gtk { };
                  lxappearance = prev.lxappearance.overrideAttrs (oldAttrs: {
                    postInstall = ''
                      wrapProgram $out/bin/lxappearance --prefix GDK_BACKEND : x11
                    '';
                  });
                  opensnitch-ui = prev.opensnitch-ui.overrideAttrs
                    (oldAttrs: rec {
                      propagatedBuildInputs = oldAttrs.propagatedBuildInputs
                        ++ [ prev.python311Packages.qt-material ];
                    });
                })
              ];
              home = {
                username = "${username}";
                homeDirectory = "/home/${username}";
                stateVersion = "24.05";
              };
            })
            ./config
          ];
        };
    };
}
