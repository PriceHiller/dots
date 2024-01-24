{
  description = "Price Hiller's home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    bob = {
      url = "path:./pkgs/bob-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = inputs @ { home-manager, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      username = "sam";
    in
    {
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      targets.genericLinux.enable = true;
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ({
            nixpkgs.overlays = [
              inputs.neovim-nightly-overlay.overlay
              inputs.emacs-overlay.overlays.emacs
              (self: super: {
                kanagawa-gtk-theme = super.callPackage ./pkgs/kanagawa-gtk { };
                lxappearance = super.lxappearance.overrideAttrs (oldAttrs: {
                  postInstall = ''
                    wrapProgram $out/bin/lxappearance --prefix GDK_BACKEND : x11
                  '';
                });
                bob-nvim = inputs.bob.overlays.${system}.default;
                opensnitch-ui = super.opensnitch-ui.overrideAttrs
                  (oldAttrs: rec {
                    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
                      super.python311Packages.qt-material
                    ];
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
