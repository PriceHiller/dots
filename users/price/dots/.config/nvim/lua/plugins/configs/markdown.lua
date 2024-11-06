return {
    {
        "wallpants/github-preview.nvim",
        ft = "markdown",
        cmd = {
            "GithubPreviewToggle",
            "GithubPreviewStart",
            "GithubPreviewStop",
        },
        config = function()
            local gpreview = require("github-preview")
            gpreview.setup({
                -- theme = {
                --     "dark"
                -- }
            })
        end,
    },
    {
        "OXY2DEV/markview.nvim",
        ft = "markdown",
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
    },
}
