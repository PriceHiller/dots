return {
    {
        "dhruvasagar/vim-table-mode",
        keys = {
            { ";;", "<cmd>TableModeRealign<CR>", desc = "Table Mode: Realign" },
            { ";t", desc = "> Table Mode" },
        },
        lazy = false,
        init = function()
            vim.g.table_mode_map_prefix = ";t"
            vim.g.table_mode_always_active = 1
            vim.g.table_mode_header_fillchar = "-"
            vim.g.table_mode_corner = "|"
        end,
    },
}
