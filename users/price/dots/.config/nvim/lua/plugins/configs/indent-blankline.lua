return {
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("ibl").setup({
                exclude = {
                    buftypes = {
                        "terminal",
                        "nofile",
                    },
                    filetypes = {
                        "help",
                        "terminal",
                        "alpha",
                        "packer",
                        "lsp-installer",
                        "lspinfo",
                        "mason.nvim",
                        "mason",
                        "man",
                        "OverseerForm",
                        "noice",
                        "lazy",
                        "NeogitStatus",
                        "NeogitHelpPopup",
                        "NeogitPopup",
                        "NeogitLogView",
                        "norg",
                        "org",
                    },
                },
                indent = {
                    repeat_linebreak = true,
                    char = "▏",
                    tab_char = "▏",
                    smart_indent_cap = true,
                },
                scope = {
                    enabled = true,
                    include = {
                        node_type = {
                            lua = {
                                "return_statement",
                                "table_constructor",
                            },
                            nix = {
                                "binding",
                            },
                        },
                    },
                    highlight = {
                        "RainbowDelimiterRed",
                        "RainbowDelimiterYellow",
                        "RainbowDelimiterBlue",
                        "RainbowDelimiterOrange",
                        "RainbowDelimiterGreen",
                        "RainbowDelimiterViolet",
                        "RainbowDelimiterCyan",
                    },
                },
            })
        end,
    },
}
