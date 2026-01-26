{ pkgs, ... }:
{
  screen-cap = pkgs.callPackage ./screen-cap/default.nix { };
  neovide = pkgs.callPackage ./neovide/package.nix { };
  Fmt = pkgs.writeShellApplication {
    name = "Fmt";
    runtimeInputs = with pkgs; [
      stylua
      gnugrep
      nixfmt
      nodePackages.prettier
      shfmt
    ];
    text = (
      ''
        #!${pkgs.bash}/bin/bash
      ''
      + builtins.readFile ./fmt.bash
    );
  };
  ciscoPacketTracer9 = pkgs.callPackage ./packettracer/pkg.nix { };
  equibop =
    # Use until equibop is updated on Nixpkgs
    # WAITING: https://github.com/NixOS/nixpkgs/pull/456790
    (import (pkgs.fetchzip {
      url = "https://github.com/Rexcrazy804/nixpkgs/archive/update-equibop.tar.gz";
      hash = "sha256-Ctx31dXlh5Ze1zSFrsNBEYtf2xVlj0UUAfThnlIG6tE=";
    }) { inherit (pkgs.stdenv.hostPlatform) system; }).equibop;
}
