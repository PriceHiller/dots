return {
    {
        "phaazon/hop.nvim",
        keys = {
            {"f", function() require("hop").hint_char1({ current_line_only = false, }) end,  desc = "Hop: Character", mode = { "" } },
            {";l", "<cmd>HopLineStart<CR>",  desc = "Hop: Line Start" },
            {";s", "<cmd>HopPattern<CR>",  desc = "Hop: Pattern" },
            {";;", "<cmd>HopWord<CR>",  desc = "Hop: Word" },
            {";a", "<cmd>HopAnywhere<CR>",  desc = "Hop: Anywhere" },
            {";v", "<cmd>HopVertical<CR>",  desc = "Hop Vertical" },
        },
        cmd = {
            "HopLineStart",
            "HopPattern",
            "HopWord",
            "HopAnywhere",
            "HopVertical",
        },
        opts = {
            keys = "etovxqpdygfblzhckisuran",
        },
    },
}
