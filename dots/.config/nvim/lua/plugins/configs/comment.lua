return {
    {
        "numToStr/Comment.nvim",
        config = true,
        keys = {
            { "gc", desc = "> Comment: Line" },
            { "gb", desc = "> Comment: Block " },
            { "gbc", desc = "Comment: Toggle block comment" },
            { "gcc", desc = "Comment: Toggle line comment" },
            { "gcO", desc = "Comment: Add comment on line above" },
            { "gco", desc = "Comment: Add comment on line below" },
            { "gcA", desc = "Comment: Add comment at end of line" },
            {
                "<leader>/",
                function()
                    local api = require("Comment.api")
                    api.toggle.linewise.current()
                end,
                desc = "Comment: Toggle Linewise",
            },
            {
                "<leader>/",
                function()
                    local api = require("Comment.api")
                    local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
                    vim.api.nvim_feedkeys(esc, "nx", false)
                    api.toggle.linewise(vim.fn.visualmode())
                end,
                desc = "Comment: Toggle Blockwise",
                mode = { "x" },
            },
        },
    },
}
