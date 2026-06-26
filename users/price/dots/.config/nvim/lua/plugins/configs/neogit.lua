return {
    {
        "neogitorg/neogit",
        cmd = { "Neogit", "NeogitLogCurrent" },
        keys = {
            { "<leader>g", desc = "> Git" },
            { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit: Open" },
        },
        config = function()
            local neogit = require("neogit")
            neogit.setup({
                treesitter_diff_highlight = true,
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
                    codediff = true,
                    telescope = true,
                },
                status = {
                    recent_commit_count = 30,
                },
                mappings = {
                    popup = {
                        ["l"] = false,
                        ["L"] = "LogPopup",
                        ["f"] = false,
                        ["F"] = "FetchPopup",
                    },
                },
            })
            vim.api.nvim_create_user_command("NeogitLogCurrent", function()
                require("neogit.popups.log.actions").log_current({
                    get_arguments = function()
                        return { "--max-count=256" }
                    end,
                    get_internal_arguments = function()
                        return { graph = true, decorate = true }
                    end,
                    state = { env = { files = {} } },
                })
            end, { desc = "Neogit: Log current branch" })
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
            "esmuellert/codediff.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },
}
