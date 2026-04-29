local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.lsp.config("nixd", {

    settings = {
        root_dir = dir,
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
