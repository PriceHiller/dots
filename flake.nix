{
  description = "Price Hiller's home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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
