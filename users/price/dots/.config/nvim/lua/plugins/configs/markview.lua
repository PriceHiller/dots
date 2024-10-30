return {
    "OXY2DEV/markview.nvim",
    lazy = false, -- Recommended
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("markview").setup({
            hybrid_modes = { "n" },
            checkboxes = {
                enable = false,
            },
            list_items = {
                enable = false,
            },
        })
        vim.cmd("Markview hybridDisable")
    end,
}
