local lspconfig = require("lspconfig")

lspconfig.nixd.setup({
    cmd = { "nixd", "--semantic-tokens=false" },
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
                    expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.orion.options',
                },
                home_manager = {
                    expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.orion.options.home-manager.users.type.getSubOptions []',
                },
            },
        },
    },
})
