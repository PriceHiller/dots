---@diagnostic disable: missing-fields
return {
    {
        "hrsh7th/nvim-cmp",
        event = { "InsertEnter", "ModeChanged" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-emoji",
            "amarakon/nvim-cmp-lua-latex-symbols",
            {
                "petertriho/cmp-git",
                dependencies = {
                    "nvim-lua/plenary.nvim",
                },
                opts = {},
            },
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "hrsh7th/cmp-calc",
            "davidsierradz/cmp-conventionalcommits",
            {
                "tamago324/cmp-zsh",
                opts = {
                    zshrc = true,
                    filetypes = { "*" },
                },
            },
            "dmitmel/cmp-cmdline-history",
            "David-Kunz/cmp-npm",
            "lukas-reineke/cmp-rg",
            "onsails/lspkind.nvim",
            "FelipeLema/cmp-async-path",
            {
                "tzachar/cmp-fuzzy-buffer",
                dependencies = {
                    "tzachar/fuzzy.nvim",
                },
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
        },
        config = function()
            local cmp = require("cmp")
            local types = require("cmp.types")
            local str = require("cmp.utils.str")
            local compare = cmp.config.compare
            local luasnip = require("luasnip")

            -- Load Snippets
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_lua").load({
                paths = vim.fn.stdpath("config") .. "/lua/plugins/snippets",
            })

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

            local function hslToRgb(h, s, l)
                h = h / 360
                s = s / 100
                l = l / 100

                local r, g, b

                if s == 0 then
                    r, g, b = l, l, l -- achromatic
                else
                    local function hue2rgb(p, q, t)
                        if t < 0 then
                            t = t + 1
                        end
                        if t > 1 then
                            t = t - 1
                        end
                        if t < 1 / 6 then
                            return p + (q - p) * 6 * t
                        end
                        if t < 1 / 2 then
                            return q
                        end
                        if t < 2 / 3 then
                            return p + (q - p) * (2 / 3 - t) * 6
                        end
                        return p
                    end

                    local q = l < 0.5 and l * (1 + s) or l + s - l * s
                    local p = 2 * l - q
                    r = hue2rgb(p, q, h + 1 / 3)
                    g = hue2rgb(p, q, h)
                    b = hue2rgb(p, q, h - 1 / 3)
                end

                local function round(num)
                    return num + (2 ^ 52 + 2 ^ 51) - (2 ^ 52 + 2 ^ 51)
                end
                return round(r * 255), round(g * 255), round(b * 255)
            end

            ---@param sources table?
            local standard_sources = function(sources)
                sources = sources or {}
                local default_sources = {
                    { name = "async_path" },
                    { name = "nvim_lsp" },
                    { name = "luasnip", max_item_count = 5 }, -- For luasnip users.
                    {
                        name = "fuzzy_buffer",
                        max_item_count = 5,
                    },
                    {
                        name = "rg",
                        keyword_length = 3,
                        max_item_count = 5,
                        option = {
                            "--smart-case",
                            "--hidden",
                            "--max-depth 4",
                        },
                    },
                    {
                        name = "lua-latex-symbols",
                        option = { cache = true },
                        trigger_characters = { "\\" },
                    },
                    { name = "zsh", max_item_count = 5 },
                    { name = "emoji", keyword_length = 2, max_item_count = 10 },
                    { name = "calc" },
                    { name = "npm", keyword_length = 2 },
                }

                vim.tbl_map(function(source)
                    table.insert(default_sources, 1, source)
                end, sources)
                return cmp.config.sources(default_sources)
            end
            cmp.setup({
                formatting = {
                    fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
                    ---@param entry cmp.Entry
                    ---@param vim_item vim.CompletedItem
                    format = function(entry, vim_item)
                        local selections = {
                            ["vim-dadbod-completion"] = { symbol = "󰆼 ", name = "DB", hl_group = "DadbodCompletion" },
                            calc = { symbol = " ", name = "Calculator", hl_group = "Calculator" },
                            orgmode = { symbol = " ", name = "Org", hl_group = "Orgmode" },
                            emoji = { symbol = "󰞅 ", name = "Emoji", hl_group = "Emoji" },
                            zsh = { symbol = " ", name = "Zsh", hl_group = "Zsh" },
                            crates = { symbol = " ", name = "Crates", hl_group = "Crates" },
                            cmdline_history = { symbol = " ", name = "Cmd History", hl_group = "CmdHistory" },
                            rg = { symbol = " ", name = "Ripgrep", hl_group = "Ripgrep" },
                            fuzzy_buffer = { symbol = "󰱼 ", name = "Buffer", hl_group = "Buffer" },
                            npm = { symbol = " ", name = "Npm,", hl_group = "Npm," },
                            conventionalcommits = { symbol = " ", name = "Commit", hl_group = "Commit" },
                            git = { symbol = "󰊢 ", name = "Git", hl_group = "Git" },
                            docker_compose_language_service = { symbol = "󰡨 ", name = "Docker", hl_group = "Docker" },
                            luasnip = { symbol = " ", name = "Snippet" },
                            ["lua-latex-symbols"] = { symbol = "󰡱 ", name = "Math", hl_group = "LuaLatexSymbol" },
                        }

                        local extra_kind_icons = {
                            TypeParameter = "",
                        }

                        local selection
                        local lsp_name
                        if entry.source.name == "nvim_lsp" then
                            lsp_name = entry.source.source.client.name
                            selection = selections[lsp_name]
                        else
                            selection = selections[entry.source.name]
                        end
                        local completion_item = vim_item
                        local abbr_max_width = 72
                        if not selection then
                            local kind = require("lspkind").cmp_format({
                                mode = "symbol_text",
                                maxwidth = abbr_max_width,
                            })(entry, vim_item)
                            if string.match(kind.kind, ".* Color$") or string.match(kind.kind, ".* Variable$") then
                                ---@type string
                                local hl = nil
                                local cmp_item = entry.cache.entries.get_completion_item
                                if cmp_item.documentation ~= nil then
                                    hl = cmp_item.documentation
                                elseif cmp_item.label ~= nil then
                                    hl = cmp_item.label
                                end

                                local function rgbToHex(red, green, blue)
                                    local function convertNumHex(num)
                                        local conversion = string.format("%x", num)
                                        if conversion:len() == 0 then
                                            return "00"
                                        elseif conversion:len() == 1 then
                                            return string.format("0%s", conversion)
                                        else
                                            return conversion
                                        end
                                    end
                                    return string.format(
                                        "#%s%s%s",
                                        convertNumHex(red),
                                        convertNumHex(green),
                                        convertNumHex(blue)
                                    )
                                end

                                if type(hl) == string then
                                    local s, _, red, green, blue = string.find(hl, "rgb.*%((%d+), (%d+), (%d+).*%)")
                                    if s ~= nil then
                                        hl = rgbToHex(red, green, blue)
                                    end

                                    local start, _, hue, saturation, lightness =
                                        hl:find("hsl.*%((%d+), (%d+)%%, (%d+)%%.*%)")
                                    if start ~= nil then
                                        red, green, blue =
                                            hslToRgb(tonumber(hue), tonumber(saturation), tonumber(lightness))
                                        hl = rgbToHex(red, green, blue)
                                    end

                                    if hl:match("^#?%x%x%x%x%x%x$") ~= nil then
                                        kind.kind_hl_group = handle_color_hl(hl)
                                        kind.kind = " Color"
                                    end
                                end
                            end

                            local strings = vim.split(kind.kind, "%s", { trimempty = true })
                            if not strings[2] then
                                strings[2] = strings[1]
                                strings[1] = extra_kind_icons[strings[1]] or ""
                            end
                            kind.kind = " " .. strings[1] .. " "
                            if not kind.menu and lsp_name then
                                kind.menu = " " .. lsp_name
                            end

                            completion_item = kind
                        else
                            completion_item.kind = " " .. selection.symbol
                            completion_item.menu = selection.symbol .. selection.name
                            if selection.hl_group then
                                completion_item.kind_hl_group = "CmpCustomSelection" .. selection.hl_group
                            end
                        end

                        if not completion_item.abbr then
                            local word = entry:get_insert_text()
                            word = str.oneline(word)
                            completion_item.abbr = word
                        end

                        --- If the completion item looks like a file path and exists, go ahead and
                        --- abbreviate it relative to the home directory
                        if
                            vim.fn.isdirectory(completion_item.abbr) == 1
                            or vim.fn.filereadable(completion_item.abbr) == 1
                        then
                            completion_item.abbr = vim.fn.fnamemodify(completion_item.abbr, ":~")
                        end

                        if string.len(completion_item.abbr) >= abbr_max_width then
                            local before = string.sub(completion_item.abbr, 1, math.floor((abbr_max_width - 3) / 2))
                            completion_item.abbr = before .. "..."
                        end

                        -- concatenates the string
                        return completion_item
                    end,
                },
                view = {
                    entries = {
                        name = "custom",
                        selection_order = "near_cursor",
                    },
                },
                matching = {
                    disallow_partial_fuzzy_matching = false,
                    disallow_fullfuzzy_matching = false,
                    disallow_partial_matching = false,
                    disallow_fuzzy_matching = false,
                    disallow_prefix_unmatching = false,
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
                experimental = { ghost_text = { hl_group = "CmpGhostText" } },
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                mapping = {
                    ["<C-s>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
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
                sources = standard_sources(),
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        compare.locality,
                        compare.recently_used,
                        compare.score,
                        require("cmp_fuzzy_buffer.compare"),
                        compare.offset,
                        compare.exact,
                        -- Copied from cmp-under-comparator
                        function(entry1, entry2)
                            local _, entry1_under = entry1.completion_item.label:find("^_+")
                            local _, entry2_under = entry2.completion_item.label:find("^_+")
                            entry1_under = entry1_under or 0
                            entry2_under = entry2_under or 0
                            if entry1_under > entry2_under then
                                return false
                            elseif entry1_under < entry2_under then
                                return true
                            end
                        end,
                    },
                },
            })

            -- Git Commit Completions
            cmp.setup.filetype("gitcommit", {
                sources = standard_sources({
                    { name = "git", priority = 20 },
                    { name = "conventionalcommits", priority = 19 },
                }),
            })

            cmp.setup.filetype("octo", {
                sources = standard_sources({
                    { name = "git", priority = 20 },
                }),
            })

            cmp.setup.filetype(
                "sql",
                { sources = standard_sources({ { name = "vim-dadbod-completion", priority = 20 } }) }
            )
            cmp.setup.filetype(
                "mysql",
                { sources = standard_sources({ { name = "vim-dadbod-completion", priority = 20 } }) }
            )
            cmp.setup.filetype(
                "plsql",
                { sources = standard_sources({ { name = "vim-dadbod-completion", priority = 20 } }) }
            )
            cmp.setup.filetype("toml", { sources = standard_sources({ { name = "crates" } }) })
            cmp.setup.filetype("org", { sources = standard_sources({ { name = "orgmode", priority = 20 } }) })

            -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ name = "fuzzy_buffer" }),
            })

            cmp.setup.cmdline("?", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ name = "fuzzy_buffer" }),
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = {
                                "!",
                            },
                        },
                        priority = 100,
                    },
                    { name = "cmdline_history", max_item_count = 3 },
                    { name = "fuzzy_buffer", max_item_count = 3 },
                }),
            })
        end,
    },
}
