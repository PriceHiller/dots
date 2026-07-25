return {
    {
        "esmuellert/codediff.nvim",
        event = "VeryLazy",
        keys = {
            { "<localleader>dc", "<cmd>CodeDiff<CR>", desc = "Code Diff: Open" },
        },
        cmd = "CodeDiff",
        config = function()
            require("codediff").setup({
                explorer = {
                    view_mode = "tree",
                },
            })
        end,
    },
}
