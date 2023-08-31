return {
    {
        "3rd/image.nvim",
        build = function()
            ---@param out SystemCompleted
            vim.system({"luarocks", "--lua-version", "5.1", "--local", "install", "magick"}, {}, function (out)
                if out.code ~= 0 then
                    error("Failed to install `magick` luarock for image.nvim!", vim.log.levels.ERROR)
                end
            end)
        end,
        ft = {"markdown", "norg"},
        config = function()
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
            require("image").setup({
                window_overlap_clear_enabled = true,
            })
        end
    },
    {
        "nvim-neorg/neorg",
        build = ":Neorg sync-parsers", -- This is the important bit!
        cmd = { "Neorg" },
        ft = { "norg" },
        keys = {
            { "<leader>o",  desc = "> Neorg" },
            { "<leader>oj", ":Neorg journal custom<CR>", desc = "Neorg: Journal" },
            { "<leader>ot", ":Neorg toc<CR>",            desc = "Neorg: Table of Contents" }
        },
        config = function()
            require("neorg").setup({
                load = {
                    ["core.defaults"] = {},
                    ["core.completion"] = {
                        config = {
                            engine = "nvim-cmp"
                        }
                    },
                    ["core.neorgcmd"] = {},
                    ["core.summary"] = {},
                    ["core.journal"] = {
                        config = {
                            stategy = "flat"
                        },
                        workspace = "default"
                    },
                    ["core.dirman"] = {
                        config = {
                            default_workspace = "default",
                            workspaces = {
                                default = "~/Notes"
                            },
                            index = "index.norg"
                        }
                    },
                    ["core.concealer"] = {
                        config = {
                            folds = false,
                            icon_preset = "diamond",
                            icons = {
                                code_block = {
                                    conceal = true,
                                    content_only = true,
                                },
                            },
                        }
                    },
                    ["core.integrations.treesitter"] = {
                        config = {
                            configure_parsers = true,
                            install_parsers = true
                        }
                    },
                    ["core.qol.todo_items"] = {
                        config = {
                            create_todo_items = true,
                            create_todo_parents = true
                        }
                    },
                    ["core.ui"] = {},
                    ["core.ui.calendar"] = {}
                }
            })
        end,
    }
}
