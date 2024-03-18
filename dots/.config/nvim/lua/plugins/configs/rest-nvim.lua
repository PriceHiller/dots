return {
    {
        "rest-nvim/rest.nvim",
        ft = { "http" },
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require("rest-nvim").setup({})
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            {
                "vhyrro/luarocks.nvim",
                config = function()
                    require("luarocks").setup({})
                end,
            },
        },
    },
}
