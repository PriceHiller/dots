-- TODO: Make this more general, this will support my own NixOS config and dot file
-- stuff, but not generally usable for other projects. Would be good to use something
-- like `.nvim.lua` for this or whatever else works 🤷.
return {
    cmd = { "nixd" },
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "nixfmt" },
            },
            options = {
                nixos = {
                    expr = "(let pkgs = import <nixpkgs> { }; in (pkgs.lib.evalModules { modules = (import <nixpkgs/nixos/modules/module-list.nix>) ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options",
                },
                home_manager = {
                    expr = "(let pkgs = import <nixpkgs> { }; lib = import <home-manager/modules/lib/stdlib-extended.nix> pkgs.lib; in (lib.evalModules { modules = (import <home-manager/modules/modules.nix>) { inherit lib pkgs; check = false; }; })).options",
                },
            },
        },
    },
}
