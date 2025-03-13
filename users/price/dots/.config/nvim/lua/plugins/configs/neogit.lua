return {
    {
        "neogitorg/neogit",
        cmd = { "Neogit" },
        keys = {
            { "<leader>g", desc = "> Git" },
            { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit: Open" },
        },
        config = function()
            local neogit = require("neogit")
            neogit.setup({
                disable_insert_on_commit = true,
                disable_commit_confirmation = true,
                disable_builtin_notifications = true,
                auto_refresh = true,
                disable_signs = true,
                preview_buffer = {
                    kind = "split",
                },
                filewatcher = {
                    enabled = true,
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
            vim.api.nvim_create_autocmd("User", {
                pattern = "Neogit*",
                desc = "Handle Neogit Refreshes",
                callback = function()
                    vim.schedule_wrap(function()
                        neogit.status:refresh()
                    end)
                end,
            })
            vim.api.nvim_create_autocmd("BufWinEnter", {
                pattern = "NeogitStatus",
                desc = "Set some unset options from Neogit",
                callback = function()
                    vim.schedule(function()
                        vim.wo.foldcolumn = "auto"
                    end)
                end,
            })
        end,
        dependencies = {
            "sindrets/diffview.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },
}
