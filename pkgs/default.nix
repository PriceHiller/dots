{ pkgs, ... }:
{
  screen-cap = pkgs.callPackage ./screen-cap/default.nix { };
  # neovide = pkgs.callPackage ./neovide/package.nix { };
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
