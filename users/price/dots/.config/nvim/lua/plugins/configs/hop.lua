return {
    {
        "smoka7/hop.nvim",
        keys = {
            {
                "f",
                function()
                    if vim.bo.filetype == "neo-tree" then
                        ---@diagnostic disable-next-line: missing-fields
                        require("hop").hint_lines({})
                    else
                        ---@diagnostic disable-next-line: missing-fields
                        require("hop").hint_char1({ current_line_only = false })
                    end
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
