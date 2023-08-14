return {
    {
        "echasnovski/mini.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("mini.align").setup({})
            require("mini.cursorword").setup({})
        end,
    },
}
