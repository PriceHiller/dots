return {
    {
        "nvim-neorg/neorg",
        build = ":Neorg sync-parsers", -- This is the important bit!
        cmd = { "Neorg" },
        ft = { "norg" },
        dependencies = {
            { "nvim-treesitter/nvim-treesitter" },
        },
        keys = {
            { "<leader>o",  desc = "> Neorg" },
            { "<leader>oj", ":Neorg journal custom<CR>", desc = "Neorg: Journal" },
            { "<leader>ot", ":Neorg toc<CR>",            desc = "Neorg: Table of Contents" },
        },
        config = function()
            require("neorg").setup({
                load = {
                    ["core.defaults"] = {},
                    ["core.completion"] = {
                        config = {
                            engine = "nvim-cmp",
                        },
                    },
                    ["core.neorgcmd"] = {},
                    ["core.summary"] = {},
                    ["core.journal"] = {
                        config = {
                            stategy = "flat",
                        },
                        workspace = "default",
                    },
                    ["core.dirman"] = {
                        config = {
                            default_workspace = "default",
                            workspaces = {
                                default = "~/Notes",
                            },
                            index = "index.norg",
                        },
                    },
                    ["core.concealer"] = {
                        config = {
                            folds = true,
                            icons = {
                                code_block = {
                                    conceal = true,
                                    content_only = true,
                                },
                                heading = {
                                    icons = {
                                        "󰀘",
                                        "",
                                        "󰺕",
                                        "",
                                        "󰬪",
                                        "󱆭",
                                    }
                                }
                            },
                        },
                    },
                    ["core.integrations.treesitter"] = {
                        config = {
                            configure_parsers = true,
                            install_parsers = true,
                        },
                    },
                    ["core.qol.todo_items"] = {
                        config = {
                            create_todo_items = true,
                            create_todo_parents = true,
                        },
                    },
                    ["core.ui"] = {},
                    ["core.ui.calendar"] = {},
                    ["core.itero"] = {},
                    ["core.promo"] = {}
                },
            })
            if vim.bo.filetype == "norg" then
                vim.cmd.edit()
            end
        end,
    },
}
