---@diagnostic disable: missing-fields
return {
    {
        "hrsh7th/nvim-cmp",
        event = { "BufRead", "BufNewFile", "InsertEnter", "ModeChanged", "WinNew" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-emoji",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "hrsh7th/cmp-calc",
            "davidsierradz/cmp-conventionalcommits",
            "tamago324/cmp-zsh",
            "dmitmel/cmp-cmdline-history",
            "David-Kunz/cmp-npm",
            "lukas-reineke/cmp-rg",
            "onsails/lspkind.nvim",
            "f3fora/cmp-spell",
            "FelipeLema/cmp-async-path",
            {
                "petertriho/cmp-git",
                dependencies = { "nvim-lua/plenary.nvim" },
                opts = { filetypes = { "*" } },
            },
            -- Snippets
            {
                "L3MON4D3/LuaSnip",
                build = "make install_jsregexp",
                dependencies = {
                    "rafamadriz/friendly-snippets",
                    "saadparwaiz1/cmp_luasnip",
                },
            },
            {
                "saecki/crates.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
                ft = "toml",
                config = true,
            },
            {
                "tzachar/cmp-fuzzy-buffer",
                dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
            },
        },
        config = function()
            local cmp = require("cmp")
            local types = require("cmp.types")
            local str = require("cmp.utils.str")
            local compare = cmp.config.compare
            local luasnip = require("luasnip")

            -- Load Snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            local colors_bg_color = vim.api.nvim_get_hl(0, { name = "CmpCustomSelectionColor" }).bg
            local cached_colors = {}
            local function handle_color_hl(color_entry)
                local cached_hl_grp = cached_colors[color_entry]
                if cached_hl_grp ~= nil then
                    return cached_hl_grp
                else
                    local hl_grp = string.format("CmpCustomColor%s", color_entry:sub(2))
                    vim.api.nvim_set_hl(0, hl_grp, { fg = color_entry, bg = colors_bg_color or "#FF0000" })
                    cached_colors[color_entry] = hl_grp
                    return hl_grp
                end
            end

            cmp.setup({
                formatting = {
                    fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
                    ---@param entry cmp.Entry
                    ---@param vim_item vim.CompletedItem
                    format = function(entry, vim_item)
                        local selections = {
                            fuzzy_buffer = { symbol = "󰱼 ", name = "Buffer", hl_group = "Buffer" },
                            calc = { symbol = " ", name = "Calculator", hl_group = "Calculator" },
                            neorg = { symbol = "󱍤 ", name = "Neorg", hl_group = "Neorg" },
                            emoji = { symbol = "󰞅 ", name = "Emoji", hl_group = "Emoji" },
                            zsh = { symbol = " ", name = "Zsh", hl_group = "Zsh" },
                            crates = { symbol = " ", name = "Crates", hl_group = "Crates" },
                            cmdline_history = { symbol = " ", name = "Cmd History", hl_group = "CmdHistory" },
                            rg = { symbol = " ", name = "Ripgrep", hl_group = "Ripgrep" },
                            npm = { symbol = " ", name = "Npm,", hl_group = "Npm," },
                            conventionalcommits = { symbol = " ", name = "Commit", hl_group = "Commit" },
                            spell = { symbol = "󰏪 ", name = "Spell", hl_group = "Spell" },
                            git = { symbol = "󰊢 ", name = "Git", hl_group = "Git" },
                        }

                        local extra_kind_icons = {
                            TypeParameter = "",
                        }

                        local selection = selections[entry.source.name]
                        if not selection then
                            local kind = require("lspkind").cmp_format({
                                mode = "symbol_text",
                                maxwidth = 50,
                            })(entry, vim_item)
                            if string.match(kind.kind, ".* Color$") then
                                kind.kind_hl_group =
                                    handle_color_hl(entry.cache.entries.get_completion_item.documentation)
                            end

                            local strings = vim.split(kind.kind, "%s", { trimempty = true })
                            if not strings[2] then
                                strings[2] = strings[1]
                                strings[1] = extra_kind_icons[strings[1]] or ""
                            end
                            kind.kind = " " .. strings[1] .. " "

                            return kind
                        else
                            local word = entry:get_insert_text()
                            if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
                                word = vim.lsp.util.parse_snippet(word)
                            end
                            word = str.oneline(word)

                            -- concatenates the string
                            local max = 50
                            if string.len(word) >= max then
                                local before = string.sub(word, 1, math.floor((max - 3) / 2))
                                word = before .. "..."
                            end
                            vim_item.kind = " " .. selection.symbol
                            vim_item.menu = selection.symbol .. selection.name
                            vim_item.kind_hl_group = "CmpCustomSelection" .. selection.hl_group
                            vim_item.abbr = word
                            return vim_item
                        end
                    end,
                },
                view = {
                    entries = {
                        name = "custom",
                        selection_order = "near_cursor",
                    },
                },
                window = {
                    documentation = {
                        side_padding = 0,
                    },
                    completion = {
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                        col_offset = -3,
                        side_padding = 0,
                    },
                },
                experimental = { ghost_text = { hl_group = "Comment" }, native_menu = false },
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                mapping = {
                    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
                    ["<C-e>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ["<C-Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<C-S-Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 11 },
                    { name = "luasnip", priority = 10 }, -- For luasnip users.
                    { name = "fuzzy_buffer", priority = 9, keyword_length = 3, max_item_count = 10 },
                    {
                        name = "rg",
                        priority = 7,
                        keyword_length = 3,
                        max_item_count = 10,
                    },
                    { name = "async_path", priority = 6 },
                    { name = "zsh", priority = 5 },
                    { name = "git", priority = 4 },
                    { name = "emoji", keyword_length = 2 },
                    { name = "neorg" },
                    { name = "calc" },
                    { name = "npm", keyword_length = 2 },
                    { name = "spell", keyword_length = 2 },
                }),
                sorting = {
                    comparators = {
                        compare.score,
                        compare.offset,
                        compare.recently_used,
                        compare.exact,
                        require("cmp_fuzzy_buffer.compare"),
                        compare.kind,
                        compare.sort_text,
                        compare.length,
                        compare.order,
                    },
                },
            })

            -- Git Commit Completions
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "conventionalcommits", priority = 3 },
                    { name = " git", priority = 2 },
                    { name = "emoji", keyword_length = 2, priority = 1 },
                }),
            })

            cmp.setup.filetype("toml", { sources = cmp.config.sources({ { name = "crates" } }) })

            -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "fuzzy_buffer" } }),
            })

            cmp.setup.cmdline("?", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "fuzzy_buffer" } }),
            })

            cmp.setup.cmdline("@", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "fuzzy_buffer" },
                    { name = "cmdline_history" },
                }),
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = { "!" },
                        },
                    },
                    { name = "cmdline_history" },
                    { name = "fuzzy_buffer" },
                }),
            })
        end,
    },
}