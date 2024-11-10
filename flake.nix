{
  description = "Price Hiller's home manager configuration";

  inputs = {
    nix.url = "github:nixos/nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    hyprland.url = "github:hyprwm/Hyprland";
    wezterm.url = "github:wez/wezterm?dir=nix";
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
    neovim-src = {
      url = "github:neovim/neovim";
      flake = false;
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        neovim-src.follows = "neovim-src";
        nixpkgs.follows = "nixpkgs";
      };
    };
    secrets = {
      url = "git+file:secrets?submodules=1";
      flake = false;
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
      mkHomeCfg =
        user: home-config:
        let
          username = "${builtins.head (builtins.match "(.+)(@.+)?" user)}";
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            clib = (import ./lib { lib = nixpkgs.lib; });
            inherit inputs;
          };
          modules = [
            {
              imports = [ inputs.agenix.homeManagerModules.default ];
              nixpkgs.overlays = [
                inputs.emacs-overlay.overlays.default
                inputs.neovim-nightly-overlay.overlays.default
                inputs.fenix.overlays.default
                self.overlays.modifications
                self.overlays.additions
              ];
              home = {
                stateVersion = "24.11";
                username = "${username}";
                homeDirectory = "/home/${username}";
              };
            }
            home-config
          ];
        };
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      packages = forAllSystems (pkgs: import ./pkgs pkgs);
      homeConfigurations = builtins.mapAttrs mkHomeCfg { "price" = ./users/price/home.nix; };
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
        formatting =
          pkgs.runCommand "check-fmt"
            {
              buildInputs = with pkgs; [
                fd
                (import ./pkgs { inherit pkgs; }).Fmt
              ];
            }
            ''
              set -eEuo pipefail
              fd --exec-batch=Fmt
              touch $out
            '';
      });
      apps = forAllSystems (pkgs: {
        home-manager-init = {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "home-manager-init";
              runtimeInputs = with pkgs; [
                git
                nix
              ];
              text = ''
                #!${pkgs.bash}/bin/bash
                cd "$(git rev-parse --show-toplevel)"
                nix run --extra-experimental-features 'nix-command flakes pipe-operators' github:nix-community/home-manager -- switch --extra-experimental-features 'nix-command flakes' --flake "git+file://$(pwd)?submodules=1" "$@"
              '';
            }
          }/bin/home-manager-init";
        };
        install-host = {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "install-host";
              runtimeInputs = with pkgs; [
                openssh
                coreutils-full
                git
                agenix
                nix
              ];
              text = (
                ''
                  #!${pkgs.bash}/bin/bash
                  # The below `cd` invocation ensures the installer is running from the toplevel of
                  # the flake and thus has correct paths available.
                  cd "$(git rev-parse --show-toplevel)"
                ''
                + builtins.readFile ./scripts/install-host.bash
              );
            }
          }/bin/install-host";
        };
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
              modules = [
                ./modules/btrfs-rollback.nix
                inputs.lanzaboote.nixosModules.lanzaboote
                inputs.impermanence.nixosModules.impermanence
                inputs.agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                {
                  config = {
                    nixpkgs.overlays = [
                      self.overlays.modifications
                      self.overlays.additions
                    ];
                  };
                }
                {
                  config =
                    (import "${inputs.secrets}" {
                      agenix = false;
                      inherit clib;
                    }).${hostname};
                }
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
                ./modules/btrfs-rollback.nix
                inputs.impermanence.nixosModules.impermanence
                inputs.agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                {
                  config =
                    (import "${inputs.secrets}" {
                      agenix = false;
                      inherit clib;
                    }).${hostname};
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
              sshUser = "price";
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos outputs.nixosConfigurations.luna;
            };
          };
        };
    };
}
