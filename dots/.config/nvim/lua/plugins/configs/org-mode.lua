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
        ft = { "org" },
        keys = {
            { "<leader>o",  desc = "> Org" },
        },
        config = function()
            -- Load treesitter grammar for org
            require("orgmode").setup_ts_grammar()

            -- Setup orgmode
            require("orgmode").setup({
                org_agenda_files = "~/orgfiles/**/*",
                org_default_notes_file = "~/orgfiles/refile.org",
            })
            if vim.bo.filetype == "org" then
                vim.cmd.edit()
            end
        end,
    }
}
