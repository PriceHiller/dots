return {
    {
        "dhruvasagar/vim-table-mode",
        keys = {
            { ";;", "<cmd>TableModeRealign<CR>", desc = "Table Mode: Realign" }
        },
        init = function()
            vim.g.table_mode_always_active = 1
            vim.g.table_mode_header_fillchar = '-'
            vim.g.table_mode_corner = '|'
        end
    }
}
