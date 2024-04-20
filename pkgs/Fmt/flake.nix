{
  description = "Flake for custom formatting script";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.writeShellApplication {
          name = "Fmt";
          runtimeInputs = with pkgs; [
            stylua
            gnugrep
            nixfmt-rfc-style
            nodePackages.prettier
            shfmt
          ];
          text = (''
            #!${pkgs.bash}/bin/bash
          '' + builtins.readFile ./fmt.bash);
        };
      }) // {
        overlays.default = final: prev: {
          Fmt = self.packages.${final.system}.default;
        };
      };
}
