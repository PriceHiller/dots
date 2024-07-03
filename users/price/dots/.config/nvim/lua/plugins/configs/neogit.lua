return {
    {
        "neogitorg/neogit",
        cmd = { "Neogit" },
        keys = {
            { "<leader>g", desc = "> Git" },
            { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit: Open" },
        },
        config = function()
            require("neogit").setup({
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
        end,
        dependencies = {
            "sindrets/diffview.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },
}
