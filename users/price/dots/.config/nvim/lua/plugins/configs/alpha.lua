return {
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        init = function()
            vim.api.nvim_create_autocmd("BufEnter", {
                once = true,
                callback = function()
                    local f = vim.fn.expand("%:p")
                    if vim.fn.isdirectory(f) == 0 then
                        require("alpha")
                        return true
                    end
                end,
            })
        end,
        lazy = true,
        opts = function()
            -- helper function for utf8 chars
            local function getCharLen(s, pos)
                local byte = string.byte(s, pos)
                if not byte then
                    return nil
                end
                return (byte < 0x80 and 1) or (byte < 0xE0 and 2) or (byte < 0xF0 and 3) or (byte < 0xF8 and 4) or 1
            end

            local function applyColors(logo, colors, logoColors)
                local header = {
                    val = logo,
                    opts = {
                        hl = {},
                    },
                }

                for key, color in pairs(colors) do
                    local name = "Alpha" .. key
                    vim.api.nvim_set_hl(0, name, color)
                    colors[key] = name
                end

                for i, line in ipairs(logoColors) do
                    local highlights = {}
                    local pos = 0

                    for j = 1, #line do
                        local opos = pos
                        pos = pos + getCharLen(logo[i], opos + 1)

                        local color_name = colors[line:sub(j, j)]
                        if color_name then
                            table.insert(highlights, { color_name, opos, pos })
                        end
                    end

                    table.insert(header.opts.hl, highlights)
                end
                return header
            end
            -- Thanks to https://github.com/goolord/alpha-nvim/discussions/16#discussioncomment-10062303
            local header = applyColors({
                [[  ███       ███  ]],
                [[  ████      ████ ]],
                [[  ████     █████ ]],
                [[ █ ████    █████ ]],
                [[ ██ ████   █████ ]],
                [[ ███ ████  █████ ]],
                [[ ████ ████ ████ ]],
                [[ █████  ████████ ]],
                [[ █████   ███████ ]],
                [[ █████    ██████ ]],
                [[ █████     █████ ]],
                [[ ████      ████ ]],
                [[  ███       ███  ]],
                [[                    ]],
                [[  N  E  O  V  I  M  ]],
            }, {
                ["b"] = { fg = "#3399ff", ctermfg = 33 },
                ["a"] = { fg = "#53C670", ctermfg = 35 },
                ["g"] = { fg = "#39ac56", ctermfg = 29 },
                ["h"] = { fg = "#33994d", ctermfg = 23 },
                ["i"] = { fg = "#33994d", bg = "#39ac56", ctermfg = 23, ctermbg = 29 },
                ["j"] = { fg = "#53C670", bg = "#33994d", ctermfg = 35, ctermbg = 23 },
                ["k"] = { fg = "#30A572", ctermfg = 36 },
            }, {
                [[  kkkka       gggg  ]],
                [[  kkkkaa      ggggg ]],
                [[ b kkkaaa     ggggg ]],
                [[ bb kkaaaa    ggggg ]],
                [[ bbb kaaaaa   ggggg ]],
                [[ bbbb aaaaaa  ggggg ]],
                [[ bbbbb aaaaaa igggg ]],
                [[ bbbbb  aaaaaahiggg ]],
                [[ bbbbb   aaaaajhigg ]],
                [[ bbbbb    aaaaajhig ]],
                [[ bbbbb     aaaaajhi ]],
                [[ bbbbb      aaaaajh ]],
                [[  bbbb       aaaaa  ]],
                [[                    ]],
                [[  a  a  a  b  b  b  ]],
            })
            header.type = "text"
            header.opts.position = "center"

            local vim_version = {
                type = "text",
                val = function()
                    local version = vim.version()
                    if version.build ~= vim.NIL then
                        return ("─────── v%s.%s.%s+%s ───────"):format(
                            version.major,
                            version.minor,
                            version.patch,
                            version.build
                        )
                    end
                    return ("─────── v%s.%s.%s ───────"):format(
                        version.major,
                        version.minor,
                        version.patch
                    )
                end,
                opts = { position = "center", hl = "@boolean" },
            }

            local plugins_loaded = {
                type = "text",
                val = function()
                    local lazy_stats = require("lazy").stats()
                    local plugin_count = lazy_stats.count
                    local loaded_plugins = lazy_stats.loaded
                    local plugin_load_time = string.format("%.2f", lazy_stats.startuptime)
                    return " "
                        .. loaded_plugins
                        .. "/"
                        .. plugin_count
                        .. " plugins loaded in "
                        .. plugin_load_time
                        .. "ms"
                end,

                opts = { hl = "@keyword.conditional", position = "center" },
            }

            vim.api.nvim_set_hl(0, "AlphaPluginUpdate", { link = "@string" })
            local lstatus = require("lazy.status")
            local plugin_info = {
                type = "text",
                val = function()
                    if lstatus.has_updates() and lstatus.updates() then
                        vim.api.nvim_set_hl(0, "AlphaPluginUpdate", { link = "@keyword.return", force = true })
                        return "Plugin updates available!"
                    else
                        vim.api.nvim_set_hl(0, "AlphaPluginUpdate", { link = "@string", force = true })
                        return "All plugins up to date"
                    end
                end,

                opts = {
                    hl = "AlphaPluginUpdate",
                    position = "center",
                },
            }

            local datetime = {
                type = "text",
                val = function()
                    return vim.fn.strftime("%c")
                end,
                opts = { hl = "@variable.member", position = "center" },
            }

            -- Menu
            local button = function(sc, txt, keybind)
                local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

                local opts = {
                    position = "center",
                    text = txt,
                    shortcut = sc,
                    cursor = 2,
                    width = 30,
                    align_shortcut = "right",
                    hl_shortcut = "Number",
                    hl = "Function",
                }
                if keybind then
                    opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true, nowait = true } }
                end

                return {
                    type = "button",
                    val = txt,
                    on_press = function()
                        local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
                        vim.api.nvim_feedkeys(key, "normal", false)
                    end,
                    opts = opts,
                }
            end

            -- Set menu
            local buttons = {
                type = "group",
                val = {
                    button("e", "  New File", ":ene <BAR> startinsert <CR>"),
                    button("f", "󰈞  Find File", ":Telescope find_files<CR>"),
                    button("r", "󱝏  Recent", ":Telescope smart_open<CR>"),
                    button("s", "  Settings", "<cmd>e ~/.config/nvim/<CR>"),
                    button("u", "  Update Plugins", ":Lazy sync<CR>"),
                    button("q", "  Quit", ":qa<CR>"),
                },
                opts = { spacing = 0 },
            }

            -- Footer 2, fortune
            local fortune = {
                type = "text",
                val = require("alpha.fortune")(),
                opts = { position = "center", hl = "Comment" },
            }

            local padding = function(pad_amount)
                return { type = "padding", val = pad_amount }
            end
            local opts = {
                layout = {
                    padding(10),
                    header,
                    padding(1),
                    vim_version,
                    padding(1),
                    datetime,
                    padding(1),
                    plugin_info,
                    padding(1),
                    plugins_loaded,
                    padding(1),
                    buttons,
                    padding(1),
                    fortune,
                },
                opts = { margin = 5 },
            }
            vim.api.nvim_create_autocmd("User", {
                pattern = "AlphaReady",
                desc = "Alpha Main Handler",
                callback = function(args)
                    vim.opt_local.cursorline = false

                    local alpha_timer = vim.loop.new_timer()
                    ---@diagnostic disable-next-line: need-check-nil
                    alpha_timer:start(
                        50,
                        1000,
                        vim.schedule_wrap(function()
                            ---@diagnostic disable-next-line: param-type-mismatch
                            local success, _ = pcall(vim.cmd, "AlphaRedraw")
                            if not success and not alpha_timer:is_closing() then
                                vim.api.nvim_del_autocmd(args.id)
                                alpha_timer:close()
                            end
                        end)
                    )

                    vim.api.nvim_create_autocmd("User", {
                        pattern = "AlphaClosed",
                        desc = "Shut down alpha timer",
                        callback = function()
                            ---@diagnostic disable-next-line: need-check-nil
                            if not alpha_timer:is_closing() then
                                alpha_timer:close()
                                vim.api.nvim_del_autocmd(args.id)
                            end
                            return true
                        end,
                    })
                end,
            })

            return opts
        end,
    },
}
