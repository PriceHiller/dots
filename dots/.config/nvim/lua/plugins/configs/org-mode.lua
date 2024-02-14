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
                        list = "",
                        headlines = {
                            "󰀘",
                            "",
                            "󰺕",
                            "",
                            "󰬪",
                            "󱆭",
                        },
                    },
                },
            },
        },
        event = "VeryLazy",
        ft = { "org" },
        keys = {
            { "<leader>o", desc = "> Org" },
        },
        config = function()
            -- Load treesitter grammar for org
            require("orgmode").setup_ts_grammar()
            -- Setup orgmode
            require("orgmode").setup({
                org_agenda_files = {
                    "~/Git/College/**/*",
                    "~/Notes/**/*",
                },
                -- notifications = {
                --     enabled = true,
                --     cron_enabled = true,
                --     repeater_reminder_time = { 2880, 1440, 720, 360, 180, 60, 30, 15, 10, 5, 0 },
                --     deadline_warning_reminder_time = { 2880, 1440, 720, 360, 180, 60, 30, 15, 10, 5, 0 }
                -- },
                org_id_link_to_org_use_id = true,
                org_default_notes_file = "~/Notes/notes.org",
                org_agenda_start_day = "-1d",
                calendar_week_start_day = 0,
                org_agenda_span = "month",
                org_startup_folded = "inherit",
                org_hide_emphasis_markers = true,
                org_startup_indented = true,
                org_todo_keywords = { "TODO(t)", "NEXT(n)", "|", "DONE(d)", "CANCELLED(c)" },
                win_split_mode = "auto",
                org_capture_templates = {
                    t = {
                        description = "Todo",
                        template = "* TODO %?\n %u",
                    },
                    n = {
                        description = "Note",
                        template = "* %? :note:",
                        target = "~/Notes/notes.org"
                    },
                    j = {
                        description = "Journal",
                        template = "\n* %? %U    :journal:",
                        target = "~/Notes/journal/%<%Y-%m-%d>.org",
                    },
                },
                emacs_config = {
                    config_path = "$XDG_CONFIG_HOME/emacs/init.el",
                },
            })

            vim.api.nvim_set_hl(0, "org_code_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_verbatim_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_italic_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_bold_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_underline_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_strikethrough_delimiter", { link = "@punctuation.delimiter" })
        end,
    },
}
