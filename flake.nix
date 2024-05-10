{
  description = "Price Hiller's home manager configuration";

  inputs = {
    nix.url = "github:nixos/nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bob = {
      flake = false;
      url = "github:MordechaiHadad/bob";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar = {
      url = "github:Alexays/Waybar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:guibou/nixGL";
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blog = {
      url = "git+https://git.orion-technologies.io/blog/blog";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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
                  inputs.neovim-nightly-overlay.overlay
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
            inherit inputs;
          };
          modules = [
            ({
              imports = [ inputs.agenix.homeManagerModules.default ];
              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlay
                inputs.nixgl.overlay
                inputs.emacs-overlay.overlays.default
                self.overlays.modifications
                self.overlays.additions
              ];
              home = {
                stateVersion = "24.05";
                username = "${username}";
                homeDirectory = "/home/${username}";
              };
            })
            home-config
          ];
        };
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      packages = forAllSystems (pkgs: import ./pkgs pkgs);
      homeConfigurations = builtins.mapAttrs (mkHomeCfg) {
        "price@orion" = ./users/price/home.nix;
        "sam" = ./users/sam/home.nix;
      };
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
                findutils
                (import ./pkgs { inherit pkgs; }).Fmt
              ];
            }
            ''
              set -euo pipefail
              cd "${self}"
              find . -type f | xargs Fmt
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
                nix run --extra-experimental-features 'nix-command flakes' github:nix-community/home-manager -- switch --extra-experimental-features 'nix-command flakes' --flake "git+file://$(pwd)?submodules=1" "$@"
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
          lib = (import ./lib { lib = nixpkgs.lib; }) // nixpkgs.lib;
          persist-dir = "/persist";
          defaults = {
            config = {
              nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlay ];
              environment.etc.machine-id.source = "${persist-dir}/ephemeral/etc/machine-id";
              environment.persistence.save = {
                hideMounts = true;
                persistentStoragePath = "${persist-dir}/save";
              };
              environment.persistence.ephemeral = {
                persistentStoragePath = "${persist-dir}/ephemeral";
                hideMounts = true;
                directories = [
                  "/var/lib"
                  "/etc/nixos"
                ];
              };
            };
          };
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
                inherit lib;
                inherit persist-dir;
                root-disk = "/dev/vda";
              };
              modules = [
                defaults
                inputs.impermanence.nixosModules.impermanence
                inputs.agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                {
                  config =
                    (import "${self}/secrets" {
                      agenix = false;
                      inherit lib;
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
                inherit lib;
                inherit persist-dir;
                root-disk = "/dev/nvme0n1";
                fqdn = "orion-technologies.io";
              };
              modules = [
                defaults
                inputs.impermanence.nixosModules.impermanence
                inputs.agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                {
                  config =
                    (import "${self}/secrets" {
                      agenix = false;
                      inherit lib;
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
          orion = {
            hostname = "orion";
            fastConnection = true;
            profiles.system = {
              sshUser = "price";
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos outputs.nixosConfigurations.orion;
            };
          };
          luna = {
            hostname = "luna.hosts.orion-technologies.io";
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
