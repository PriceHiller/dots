return {
    {
        "phaazon/hop.nvim",
        keys = {
            {
                "f",
                function()
                    require("hop").hint_char1({ current_line_only = false })
                end,
                desc = "Hop: Character",
                mode = { "" },
            },
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
