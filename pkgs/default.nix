{ pkgs, ... }:
{
  bob-nvim = pkgs.callPackage ./bob-nvim.nix {
    rustPlatform = pkgs.rustPlatform;
    fetchFromGitHub = pkgs.fetchFromGitHub;
  };
  neovide = pkgs.callPackage ./neovide/package.nix { };
  Fmt = pkgs.writeShellApplication {
    name = "Fmt";
    runtimeInputs = with pkgs; [
      stylua
      gnugrep
      nixfmt-rfc-style
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
}
