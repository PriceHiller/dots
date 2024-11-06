return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
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
