return {
    {
        "OXY2DEV/markview.nvim",
        dependencies = { "saghen/blink.cmp" },
        lazy = false,
        config = function()
            require("markview").setup({
                preview = {
                    enable_hybrid_mode = true,
                    linewise_hybrid_mode = true,
                    hybrid_modes = { "n" },
                },
                typst = {
                    enable = false,
                },
                markdown = {
                    code_blocks = {
                        enable = false,
                    },
                    horizontal_rules = {
                        enable = false,
                    },
                    list_items = {
                        marker_dot = {
                            add_padding = false,
                        },
                        marker_parenthesis = {
                            add_padding = false
                        },
                        marker_plus = {
                            add_padding = false
                        },
                        marker_star = {
                            add_padding = false
                        },
                        marker_minus = {
                            add_padding = false
                        }

                    },
                    headings = {
                        enable = false,
                    },
                },
            })
        end,
    },
}
