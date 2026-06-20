return {
    {
        "smoka7/hop.nvim",
        keys = {
            {
                "f",
                function()
                    if
                        vim.list_contains({
                            "neo-tree",
                            "NeogitStatus",
                            "lazy",
                            "neotest-summary",
                        }, vim.bo.filetype)
                    then
                        require("hop").hint_lines({})
                    else
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
            hl_mode = "replace",
        },
    },
}
