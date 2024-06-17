return {
    {
        "neogitorg/neogit",
        cmd = { "Neogit" },
        keys = {
            { "<leader>g", desc = "> Git" },
            { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit: Open" },
        },
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*Neogit*",
                callback = function()
                    vim.opt_local.foldmethod = "manual"
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "gitcommit",
                callback = function()
                    vim.api.nvim_win_set_cursor(0, { 1, 0 })
                    vim.cmd.startinsert()
                end,
            })

            require("neogit").setup({
                disable_insert_on_commit = true,
                disable_commit_confirmation = true,
                disable_builtin_notifications = true,
                auto_refresh = true,
                auto_show_console = false,
                disable_signs = true,
                preview_buffer = {
                    kind = "split",
                },
                filewatcher = {
                    enabled = true,
                    interval = 1000,
                },
                graph_style = "unicode",
                integrations = {
                    diffview = true,
                    telescope = true,
                },
                mappings = {
                    popup = {
                        ["l"] = false,
                        ["L"] = "LogPopup",
                    },
                },
            })
        end,
        dependencies = {
            "sindrets/diffview.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },
}
