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
                    "~/Notes/**/*"
                },
                org_default_notes_file = "~/Notes/notes.org",
                org_startup_folded = "inherit",
                org_todo_keywords = { "TODO(t)", "NEXT(n)", "|", "DONE(d)", "CANCELLED(c)" },
                win_split_mode = "auto",
                org_capture_templates = {
                    t = {
                        description = "Todo",
                        template = "* TODO %?\n %u",
                    },
                    j = {
                        description = "Journal",
                        template = "\n* %? %U    :journal:",
                        target = "~/Notes/journal/%<%Y-%m-%d>.org",
                    },
                },
                emacs_config = {
                    config_path = "$HOME/.config/emacs/init.el",
                },
            })

            vim.api.nvim_set_hl(0, "org_code", { link = "@field" })
            vim.api.nvim_set_hl(0, "org_code_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_verbatim_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_italic_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_bold_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_underline_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_strikethrough_delimiter", { link = "@punctuation.delimiter" })
            if vim.bo.filetype == "org" then
                vim.cmd.edit()
            end
        end,
    },
}
