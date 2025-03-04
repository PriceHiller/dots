return {
    {},
    {
        "stevearc/quicker.nvim",
        dependencies = {
            "kevinhwang91/nvim-bqf",
        },
        lazy = false,
        keys = {
            {
                "<leader>qq",
                function()
                    require("quicker").toggle()
                end,
                desc = "Quickfix: Toggle",
            },
            {
                "<leader>qd",
                function()
                    vim.diagnostic.setqflist()
                end,
                desc = "Quickfix: Diagnostics",
            },
            {
                "<leader>ql",
                function()
                    require("quicker").toggle({ loclist = true })
                end,
                desc = "Loclist: Toggle",
            },
        },
        config = function()
            require("quicker").setup({
                highlight = {
                    lsp = false,
                    treesitter = true,
                },
                follow = {
                    enabled = true,
                },
                keys = {
                    {
                        ">",
                        function()
                            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                        end,
                        desc = "Expand quickfix context",
                    },
                    {
                        "<",
                        function()
                            require("quicker").collapse()
                        end,
                        desc = "Collapse quickfix context",
                    },
                },
            })
        end,
    },
}
