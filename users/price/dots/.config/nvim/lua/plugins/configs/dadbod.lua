return {
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            {
                "tpope/vim-dadbod",
                lazy = true,
            },
            {
                "kristijanhusak/vim-dadbod-completion",
                ft = { "sql", "mysql", "plsql" },
                lazy = true,
            },
        },
        cmd = {
            "DB",
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        ft = { "sql" },
        keys = {
            { "<leader>a", desc = "Dadbod" },
            { "<leader>aa", "<cmd>DBUIToggle<CR>", desc = "Dadbod: Toggle UI" },
            { "<leader>ac", "<cmd>DBUIAddConnection<CR>", desc = "Dadbod: Add Connection" },
            { "<leader>ab", "<cmd>DBUIFindBuffer<CR>", desc = "Dadbod: Find Buffer" },
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*sql",
                callback = function(args)
                    vim.bo[args.buf].ft = "sql"
                end
            })
            vim.g.db_ui_use_nerd_fonts = 1
        end,
    },
}
