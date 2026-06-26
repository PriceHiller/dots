return {
    {
        "ravsii/tree-sitter-d2",
        init = function()
            vim.filetype.add({
                pattern = {
                    [".*%.d2"] = "d2",
                },
            })
        end,
        ft = { "d2" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        build = "make nvim-install",
    },
}
