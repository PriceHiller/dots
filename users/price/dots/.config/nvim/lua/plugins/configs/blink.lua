return {
    {
        "folke/lazydev.nvim",
        cmd = "LazyDev",
        ft = "lua",
        opts = {
            library = {
                { path = "luassert-types/library", words = { "assert" } },
                { path = "busted-types/library", words = { "describe" } },
                { path = "${3rd}/luv/library", words = { "vim%.uv", "vim%.loop" } },
            },
        },
        dependencies = {
            { "LuaCATS/luassert", lazy = true },
            { "LuaCATS/busted", lazy = true },
        },
    },
    {
        "saghen/blink.compat",
        -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
        lazy = true,
        -- make sure to set opts so that lazy.nvim calls blink.compat's setup
        config = function()
            require("blink.compat").setup({})
        end,
    },
    {
        "saghen/blink.cmp",
        lazy = false, -- lazy loading handled internally
        dependencies = {
            { "PriceHiller/blink-nix.nvim" },
            "rafamadriz/friendly-snippets",
            {
                "L3MON4D3/LuaSnip",
                build = "make install_jsregexp",
            },
            "amarakon/nvim-cmp-lua-latex-symbols",
            "mikavilpas/blink-ripgrep.nvim",
            "moyiz/blink-emoji.nvim",
        },
        build = "cargo build --release",
        config = function()
            ---@class CustomKindMapItem
            ---@field icon string
            ---@field hlgroup string

            ---@type table<string, CustomKindMapItem>
            local custom_kind_map = {
                Dadbod = { icon = "󰆼", hlgroup = "Dadbod" },
                Emoji = { icon = "󰞅", hlgroup = "Emoji" },
                Ripgrep = { icon = "󰱼", hlgroup = "Ripgrep" },
                ["lua-latex-symbols"] = { icon = "󰿈", hlgroup = "LatexSymbol" },
                cmdline = { icon = "", hlgroup = "CommandLine" },
                Orgmode = { icon = "", hlgroup = "Orgmode" },
                Buffer = { icon = "", hlgroup = "Buffer" },
                Nix = { icon = "", hlgroup = "Nix" },
            }
            ---@diagnostic disable-next-line: missing-fields
            require("blink.cmp").setup({
                -- 'default' for mappings similar to built-in completion
                -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
                -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
                -- see the "default configuration" section below for full documentation on how to define
                -- your own keymap.
                keymap = {
                    preset = "default",
                    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                    ["<C-e>"] = { "hide", "fallback" },
                    ["<CR>"] = { "accept", "fallback" },
                    ["<C-Tab>"] = { "snippet_forward", "fallback" },
                    ["<C-A-Tab>"] = { "snippet_backward", "fallback" },
                    ["<C-S-Tab>"] = { "fallback" },
                    ["<Up>"] = { "select_prev", "fallback" },
                    ["<Down>"] = { "select_next", "fallback" },
                    ["<Tab>"] = { "select_next", "fallback" },
                    ["<S-Tab>"] = { "select_prev", "fallback" },
                    ["<C-p>"] = { "select_prev", "fallback" },
                    ["<C-n>"] = { "select_next", "fallback" },
                    ["\\"] = {
                        function(cmp)
                            cmp.show({ providers = { "lua-latex-symbols" } })
                        end,
                        "fallback",
                    },
                    ["<C-s>"] = { "scroll_documentation_up", "fallback" },
                    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                },

                cmdline = {
                    keymap = {
                        ["<CR>"] = { "accept_and_enter", "fallback" },
                    },
                    completion = {
                        list = {
                            selection = { preselect = false, auto_insert = true },
                        },
                        ghost_text = {
                            enabled = true,
                        },
                        menu = {
                            auto_show = true,
                        },
                    },
                },
                ---@diagnostic disable-next-line: missing-fields
                appearance = {
                    use_nvim_cmp_as_default = false,
                    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                    -- Adjusts spacing to ensure icons are aligned
                    nerd_font_variant = "normal",
                },

                ---@diagnostic disable-next-line: missing-fields
                sources = {
                    default = {
                        "lazydev",
                        "lsp",
                        "path",
                        "snippets",
                        "buffer",
                        "ripgrep",
                        "nix",
                        "emoji",
                        "orgmode",
                        "dadbod",
                    },
                    providers = {
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            score_offset = 100,
                        },
                        ripgrep = {
                            module = "blink-ripgrep",
                            score_offset = -5,
                            max_items = 5,
                            name = "Ripgrep",
                            --- @module "blink-ripgrep"
                            --- @type blink-ripgrep.Options
                            opts = {
                                prefix_min_len = 3,
                                additional_rg_options = {
                                    "--max-depth=4",
                                    "--one-file-system",
                                    "--hidden",
                                    "--glob=!.git/*",
                                },
                            },
                        },
                        ["lua-latex-symbols"] = {
                            name = "lua-latex-symbols",
                            module = "blink.compat.source",
                            opts = {
                                cache = true,
                            },
                        },
                        nix = {
                            name = "Nix",
                            module = "blink-nix",
                        },
                        emoji = {
                            module = "blink-emoji",
                            name = "Emoji",
                        },
                        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                        orgmode = {
                            name = "Orgmode",
                            module = "orgmode.org.autocompletion.blink",
                            score_offset = 5,
                        },
                    },
                },

                ---@diagnostic disable-next-line: missing-fields
                completion = {
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 50,
                    },
                    list = {
                        selection = { preselect = false, auto_insert = true },
                    },
                    ghost_text = {
                        enabled = true,
                    },

                    menu = {
                        winblend = vim.g.neovide and 90,
                        draw = {
                            padding = { 0, 1 },
                            components = {
                                kind_icon = {
                                    text = function(ctx)
                                        local cust_kind_item = custom_kind_map[ctx.source_name]
                                        if cust_kind_item then
                                            ctx.kind_icon = cust_kind_item.icon
                                        end
                                        return ctx.icon_gap .. ctx.kind_icon .. ctx.icon_gap
                                    end,
                                    highlight = function(ctx)
                                        local cust_kind_item = custom_kind_map[ctx.source_name]
                                        if cust_kind_item then
                                            return "BlinkCmpKindCustom" .. cust_kind_item.hlgroup
                                        end
                                        return ctx.kind_hl
                                    end,
                                },
                            },
                        },
                    },
                },
            })
        end,
    },
}
