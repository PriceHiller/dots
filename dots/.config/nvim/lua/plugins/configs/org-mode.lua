return {
    {
        "nvim-orgmode/orgmode",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter" },
            {
                "akinsho/org-bullets.nvim",
                opts = {
                    concealcursor = true,
                    symbols = {
                        headlines = {
                            "󰀘",
                            "",
                            "󰺕",
                            "",
                            "󰬪",
                            "󱆭",
                        }
                    }
                }
            }
        },
        config = function()
            -- Load treesitter grammar for org
            require("orgmode").setup_ts_grammar()

            -- Setup orgmode
            require("orgmode").setup({
                org_agenda_files = "~/Notes/**/*",
                org_default_notes_file = "~/Notes/refile.org",
                org_startup_folded = "inherit",
                calendar_week_start_day = 0,
                org_agenda_start_on_weekday = 0,
                emacs_config = {
                    config_path = "$HOME/.config/emacs/init.el"
                }
            })
            if vim.bo.filetype == "org" then
                vim.cmd.edit()
            end
        end,
    }
}
