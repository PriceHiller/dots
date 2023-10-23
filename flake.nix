{
  description = "Home Manager configuration of sam";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };


  outputs = inputs @ { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlays = with inputs; [
        neovim-nightly-overlay.overlay
      ];
    in
    {
      homeConfigurations."sam" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ({
            nixpkgs.overlays = overlays;
            imports = [ ./configurations/price ];
          })
        ];
      };
    };
}
