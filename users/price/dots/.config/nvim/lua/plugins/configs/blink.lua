return {
    {
        "folke/lazydev.nvim",
        cmd = "LazyDev",
        ft = "lua",
        opts = {
            library = {
                { path = "luassert-types/library", words = { "assert" } },
                { path = "busted-types/library", words = { "describe" } },
                { path = "luvit-meta/library", words = { "vim%.uv", "vim%.loop" } },
            },
        },
        dependencies = {
            { "Bilal2453/luvit-meta", lazy = true },
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
            "rafamadriz/friendly-snippets",
            {
                "L3MON4D3/LuaSnip",
                build = "make install_jsregexp",
            },
            "amarakon/nvim-cmp-lua-latex-symbols",
            "mikavilpas/blink-ripgrep.nvim",
        },
        build = "nix run .#build-plugin",
        config = function()
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
                    ["<C-CR>"] = { "accept", "fallback" },
                    ["<C-Tab>"] = {
                        function(cmp)
                            if cmp.snippet_active() then
                                return cmp.accept()
                            else
                                return cmp.select_and_accept()
                            end
                        end,
                        "snippet_forward",
                        "fallback",
                    },
                    ["<C-S-Tab>"] = { "snippet_backward", "fallback" },
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
                        "lsp",
                        "path",
                        "snippets",
                        "buffer",
                        "ripgrep",
                        "dadbod",
                        "lua-latex-symbols",
                    },
                    providers = {
                        ripgrep = {
                            module = "blink-ripgrep",
                            min_keyword_length = 3,
                            max_items = 5,
                            score_offset = 1,
                            name = "Ripgrep",
                            --- @module "blink-ripgrep"
                            --- @type blink-ripgrep.Options
                            opts = {
                                prefix_min_len = 3,
                                additional_rg_options = {
                                    "--smart-case",
                                    "--hidden",
                                    "--word-regexp",
                                    "--glob=!.git/*",
                                },
                            },
                        },
                        ["lua-latex-symbols"] = {
                            name = "lua-latex-symbols",
                            module = "blink.compat.source",
                            max_items = 5,
                            opts = {
                                cache = true,
                            },
                            score_offset = -3,
                        },
                        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    },
                },

                ---@diagnostic disable-next-line: missing-fields
                completion = {
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 50,
                    },
                    list = {
                        selection = "auto_insert",
                    },
                    ghost_text = {
                        enabled = true,
                    },

                    ---@diagnostic disable-next-line: missing-fields
                    menu = {
                        draw = {
                            padding = 0,
                            columns = {
                                { "kind_icon" },
                                { "label", "label_description", gap = 1 },
                            },
                            components = {
                                kind_icon = {
                                    text = function(ctx)
                                        return ctx.icon_gap .. ctx.kind_icon .. ctx.icon_gap
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
