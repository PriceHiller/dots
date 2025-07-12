{
  description = "Price Hiller's home manager configuration";

  inputs = {
    nix.url = "github:nixos/nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/24.11";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blog = {
      url = "git+https://git.price-hiller.com/blog/blog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    rofi-tools = {
      url = "github:szaffarano/rofi-tools";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    zsh-completions = {
      url = "github:zsh-users/zsh-completions";
      flake = false;
    };
    self.submodules = true;
    secrets = {
      url = ./secrets;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        agenix.follows = "agenix";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) outputs;
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs
          [
            "aarch64-linux"
            "i686-linux"
            "x86_64-linux"
            "aarch64-darwin"
            "x86_64-darwin"
          ]
          (
            system:
            function (
              import nixpkgs {
                inherit system;
                overlays = [
                  inputs.agenix.overlays.default
                  self.overlays.modifications
                  self.overlays.additions
                ];
              }
            )
          );
      treefmtEval = forAllSystems (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = forAllSystems (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      packages = forAllSystems (pkgs: import ./pkgs pkgs);
      overlays = import ./overlays { inherit inputs; };
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            age
            agenix
            age-plugin-yubikey
            nixos-rebuild
            nixos-install-tools
            pkgs.deploy-rs
          ];
          shellHook = ''
            export RULES="$PWD/secrets/secrets.nix"
          '';
        };
      });
      checks = forAllSystems (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
      nixosConfigurations =
        let
          clib = (import ./lib { lib = nixpkgs.lib; });
        in
        {
          orion =
            let
              hostname = "orion";
            in
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit self;
                inherit inputs;
                inherit outputs;
                inherit hostname;
                inherit clib;
              };
              modules =
                let
                  age-secrets = {
                    config = inputs.secrets.secrets.${hostname};
                  };
                in
                [
                  ./modules/nixos/btrfs-rollback.nix
                  ./modules/nixos/optimize-nix-store.nix
                  inputs.home-manager.nixosModules.home-manager
                  {
                    home-manager = {
                      sharedModules = [
                        inputs.nixcord.homeModules.nixcord
                        inputs.agenix.homeManagerModules.default
                        age-secrets
                        ./modules/hm/link-file.nix
                      ];
                      backupFileExtension = "hm.backup";
                      extraSpecialArgs = {
                        clib = (import ./lib { lib = nixpkgs.lib; });
                        inherit inputs;
                      };
                      useGlobalPkgs = true;
                      useUserPackages = true;
                      users.price = import ./users/price/home.nix;
                    };
                  }
                  inputs.lanzaboote.nixosModules.lanzaboote
                  inputs.impermanence.nixosModules.impermanence
                  inputs.agenix.nixosModules.default
                  inputs.disko.nixosModules.disko
                  {
                    config = {
                      nixpkgs.overlays = [
                        inputs.emacs-overlay.overlays.default
                        inputs.neovim-nightly-overlay.overlays.default
                        inputs.fenix.overlays.default
                        self.overlays.modifications
                        self.overlays.additions
                      ];
                    };
                  }
                  age-secrets
                  ./hosts/${hostname}
                ];
            };
          luna =
            let
              hostname = "luna";
            in
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit self;
                inherit inputs;
                inherit hostname;
                inherit nixpkgs;
                inherit clib;
              };
              modules = [
                ./modules/nixos/btrfs-rollback.nix
                inputs.impermanence.nixosModules.impermanence
                inputs.agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                {
                  config = inputs.secrets.secrets.${hostname};
                }
                ./hosts/${hostname}
              ];
            };
        };
      deploy.nodes =
        let
          deploy-rs = inputs.deploy-rs;
        in
        {
          luna = {
            hostname = "luna.hosts.price-hiller.com";
            fastConnection = true;
            profiles.system = {
              sshUser = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos outputs.nixosConfigurations.luna;
            };
          };
        };
    };
}
