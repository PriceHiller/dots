return {
    {
        "dhruvasagar/vim-table-mode",
        init = function ()
            vim.g.table_mode_always_active = 1
            vim.g.table_mode_header_fillchar = '-'
        end
    }
}
