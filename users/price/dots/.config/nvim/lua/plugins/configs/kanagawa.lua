local utils = require("utils.funcs")
local get_hl = utils.get_hl
local select_hl = utils.select_hl

return {
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("kanagawa").setup({
                transparent = not vim.g.neovide,
                dim_inactive = true,
                globalStatus = true,
                theme = "wave",
                colors = {
                    theme = {
                        all = {
                            ui = {
                                bg_gutter = "NONE",
                            },
                        },
                    },
                },
            })

            vim.cmd.colorscheme("kanagawa")
            local colors = require("kanagawa.colors").setup().palette

            -- HACK: This table was formed as an array to ensure the ordering of the keys. Since some
            -- highlights defined below depend on other highlights being correctly set, order is
            -- very important. Lua does not guarantee hashmaps will be in the order they are
            -- defined, thus the array.
            --
            ---@type { [1]: string, [2]: vim.api.keyset.highlight | fun(): vim.api.keyset.highlight | table<Highlight.Keys, fun(): string | integer> }[]
            local extra_hls = {
                -- For diagnostics
                { "CustomErrorBg", { bg = "#3d1b22" } },

                -- Nvim notify
                { "NvimNotifyError", { fg = colors.samuraiRed } },
                { "NvimNotifyWarn", { fg = colors.roninYellow } },
                { "NvimNotifyInfo", { fg = colors.springGreen } },
                { "NvimNotifyDebug", { fg = colors.crystalBlue } },
                { "NvimNotifyTrace", { fg = colors.oniViolet } },

                -- Built-ins
                { "StatusLineNC", { bg = nil } },
                { "menuSel", { bg = colors.sumiInk0, fg = "NONE" } },
                { "Pmenu", { fg = colors.fujiWhite, bg = colors.sumiInk2 } },
                { "WinBarNC", { bg = nil } },
                { "Visual", { bg = colors.sumiInk5 } },
                { "CursorLine", { bg = colors.sumiInk4 } },
                { "CursorLineNr", { fg = colors.roninYellow } },
                { "CursorLineFold", { fg = colors.crystalBlue } },
                { "LightBulbSign", { fg = colors.crystalBlue } },
                { "WinSeparator", { fg = colors.fujiGray } },
                { "StatusLine", { fg = colors.fujiWhite, bg = colors.sumiInk0 } },
                { "WinBar", { link = "StatusLine" } },

                -- Gitsigns Colors
                { "GitSignsAdd", { fg = colors.autumnGreen } },
                { "GitSignsDelete", { fg = colors.autumnRed } },
                { "GitSignsChange", { fg = colors.autumnYellow } },
                { "GitSignsStagedAdd", { link = "GitSignsAdd" } },
                { "GitSignsStagedDelete", { link = "GitSignsDelete" } },
                { "GitSignsStagedChangedelete", { link = "GitSignsDelete" } },
                { "GitSignsStagedChange", { link = "GitSignsChange" } },
                { "GitSignsUntracked", { link = "GitSignsChange" } },

                -- Neogit
                { "NeogitCommandText", { fg = colors.oniViolet2 } },
                { "NeogitPopupSectionTitle", { fg = colors.crystalBlue } },
                { "NeogitPopupConfigEnabled", { fg = colors.springBlue, italic = true } },
                { "NeogitPopupActionkey", { fg = colors.surimiOrange } },
                { "NeogitPopupConfigKey", { fg = colors.peachRed } },
                { "NeogitHunkHeader", { fg = colors.crystalBlue, bg = colors.sumiInk2 } },
                { "NeogitHunkHeaderHighlight", { fg = colors.roninYellow, bg = colors.sumiInk1 } },
                { "NeogitBranch", { fg = colors.autumnYellow, bold = true } },
                { "NeogitBranchHead", { fg = colors.autumnYellow, bold = true, underline = true } },
                { "NeogitUnmergedInto", { fg = colors.surimiOrange, bold = true } },
                { "NeogitRemote", { fg = colors.carpYellow, bold = true } },
                { "NeogitDiffContext", { bg = colors.sumiInk3 } },
                { "NeogitDiffContextHighlight", { bg = colors.sumiInk4 } },
                { "NeogitCursorLine", { link = "CursorLine" } },
                { "NeogitDiffAdd", { fg = colors.autumnGreen, bg = colors.winterGreen } },
                { "NeogitDiffDelete", { fg = colors.autumnRed, bg = colors.winterRed } },
                { "NeogitDiffDeleteHighlight", { link = "DiffDelete" } },
                {
                    "NeogitDiffHeader",
                    { fg = colors.oniViolet, bg = colors.sumiInk0, bold = true },
                },
                {
                    "NeogitDiffHeaderHighlight",
                    { fg = colors.sakuraPink, bg = colors.sumiInk0, bold = true },
                },
                { "NeogitDiffAddHighlight", { link = "DiffAdd" } },
                { "NeogitStagedChanges", { fg = colors.surimiOrange, bold = true } },
                { "NeogitUnpulledChanges", { fg = colors.peachRed, bold = true } },
                { "NeogitUnmergedChanges", { fg = colors.springGreen, bold = true } },
                { "NeogitUnstagedChanges", { fg = colors.peachRed, bold = true } },
                { "NeogitUntrackedFiles", { fg = colors.peachRed, bold = true } },
                { "NeogitSectionHeader", { fg = colors.crystalBlue, bold = true } },
                { "NeogitCommitViewHeader", { fg = colors.crystalBlue, bold = true, italic = true } },
                { "NeogitFilePath", { fg = colors.autumnYellow, italic = true } },
                { "NeogitNotificationInfo", { fg = colors.springGreen, bold = true } },
                { "NeogitNotificationWarning", { fg = colors.roninYellow, bold = true } },
                { "NeogitNotificationError", { fg = colors.samuraiRed, bold = true } },

                -- Cmp
                { "CmpGhostText", { fg = colors.boatYellow1, italic = true } },
                { "CmpItemAbbrDeprecated", { fg = colors.fujiGray, bg = "NONE" } },
                { "CmpItemAbbrMatch", { fg = colors.crystalBlue, bg = "NONE" } },
                { "CmpItemAbbrMatchFuzzy", { fg = colors.crystalBlue, bg = "NONE" } },
                { "CmpItemMenu", { fg = colors.roninYellow, bg = "NONE" } },
                { "CmpItemKindField", { fg = colors.fujiWhite, bg = colors.sakuraPink } },
                { "CmpItemKindProperty", { fg = colors.fujiWhite, bg = colors.sakuraPink } },
                { "CmpItemKindEvent", { fg = colors.fujiWhite, bg = colors.sakuraPink } },
                { "CmpItemKindText", { fg = colors.fujiWhite, bg = colors.dragonBlue } },
                { "CmpItemKindEnum", { fg = colors.fujiWhite, bg = colors.crystalBlue } },
                { "CmpItemKindKeyword", { fg = colors.fujiWhite, bg = colors.surimiOrange } },
                { "CmpItemKindConstant", { fg = colors.fujiWhite, bg = colors.crystalBlue } },
                { "CmpItemKindConstructor", { fg = colors.fujiWhite, bg = colors.crystalBlue } },
                { "CmpItemKindReference", { fg = colors.fujiWhite, bg = colors.crystalBlue } },
                { "CmpItemKindFunction", { fg = colors.fujiWhite, bg = colors.oniViolet } },
                { "CmpItemKindStruct", { fg = colors.fujiWhite, bg = colors.oniViolet } },
                { "CmpItemKindClass", { fg = colors.fujiWhite, bg = colors.oniViolet } },
                { "CmpItemKindModule", { fg = colors.fujiWhite, bg = colors.oniViolet } },
                { "CmpItemKindOperator", { fg = colors.fujiWhite, bg = colors.oniViolet } },
                { "CmpItemKindVariable", { fg = colors.fujiWhite, bg = colors.peachRed } },
                { "CmpItemKindFile", { fg = colors.fujiWhite, bg = colors.autumnYellow } },
                { "CmpItemKindUnit", { fg = colors.fujiWhite, bg = colors.autumnYellow } },
                { "CmpItemKindSnippet", { fg = colors.fujiWhite, bg = colors.autumnYellow } },
                { "CmpItemKindFolder", { fg = colors.fujiWhite, bg = colors.autumnYellow } },
                { "CmpItemKindMethod", { fg = colors.fujiWhite, bg = colors.autumnGreen } },
                { "CmpItemKindValue", { fg = colors.fujiWhite, bg = colors.autumnGreen } },
                { "CmpItemKindEnumMember", { fg = colors.fujiWhite, bg = colors.autumnGreen } },
                { "CmpItemKindInterface", { fg = colors.fujiWhite, bg = colors.waveRed } },
                { "CmpItemKindColor", { fg = colors.fujiWhite, bg = colors.waveAqua2 } },
                { "CmpItemKindTypeParameter", { fg = colors.fujiWhite, bg = colors.waveAqua2 } },
                { "CmpCustomSelectionColor", { bg = colors.sumiInk5 } },
                { "CmpCustomSelectionDadbodCompletion", { fg = colors.fujiWhite, bg = colors.oniViolet } },
                { "CmpCustomSelectionGit", { fg = colors.fujiWhite, bg = colors.roninYellow } },
                { "CmpCustomSelectionBuffer", { fg = colors.fujiWhite, bg = colors.springBlue } },
                { "CmpCustomSelectionPath", { fg = colors.fujiWhite, bg = colors.autumnYellow } },
                { "CmpCustomSelectionCalculator", { fg = colors.fujiWhite, bg = colors.waveBlue2 } },
                { "CmpCustomSelectionOrgmode", { fg = colors.fujiWhite, bg = colors.waveAqua1 } },
                { "CmpCustomSelectionEmoji", { fg = colors.fujiWhite, bg = colors.carpYellow } },
                { "CmpCustomSelectionZsh", { fg = colors.fujiWhite, bg = colors.springGreen } },
                { "CmpCustomSelectionCrates", { fg = colors.fujiWhite, bg = colors.roninYellow } },
                { "CmpCustomSelectionDocker", { fg = colors.fujiWhite, bg = colors.springBlue } },
                { "CmpCustomSelectionCmdHistory", { fg = colors.fujiWhite, bg = colors.waveBlue2 } },
                { "CmpCustomSelectionRipgrep", { fg = colors.fujiWhite, bg = colors.crystalBlue } },
                { "CmpCustomSelectionNpm", { fg = colors.fujiWhite, bg = colors.peachRed } },
                { "CmpCustomSelectionCommit", { fg = colors.fujiWhite, bg = colors.peachRed } },
                { "CmpCustomSelectionSnippet", { fg = colors.fujiWhite, bg = colors.peachRed } },
                { "CmpCustomSelectionLuaLatexSymbol", { fg = colors.fujiWhite, bg = colors.surimiOrange } },

                -- Telescope
                { "TelescopeNormal", { bg = colors.sumiInk2 } },
                { "TelescopeBorder", { bg = colors.sumiInk2, fg = colors.sumiInk1 } },
                { "TelescopePromptBorder", { bg = colors.sumiInk0, fg = colors.sumiInk0 } },
                { "TelescopePromptNormal", { bg = colors.sumiInk0, fg = colors.fujiWhite } },
                { "TelescopePromptTitle", { fg = colors.sumiInk0, bg = colors.oniViolet } },
                { "TelescopePreviewTitle", { fg = colors.sumiInk0, bg = colors.sakuraPink } },
                { "TelescopePreviewNormal", { bg = colors.sumiInk4 } },
                { "TelescopePreviewBorder", { link = "TelescopePreviewNormal" } },
                { "TelescopeResultsTitle", { fg = "NONE", bg = "NONE" } },

                { "IlluminatedWordText", { bg = colors.waveBlue2 } },
                { "IlluminatedWordRead", { bg = colors.waveBlue2 } },
                { "IlluminatedWordWrite", { bg = colors.waveBlue2 } },
                { "rainbowcol1", { fg = colors.oniViolet } },
                { "rainbowcol2", { fg = colors.crystalBlue } },
                { "rainbowcol3", { fg = colors.lightBlue } },
                { "rainbowcol4", { fg = colors.sakuraPink } },
                { "rainbowcol5", { fg = colors.springGreen } },
                { "rainbowcol6", { fg = colors.springViolet2 } },
                { "rainbowcol7", { fg = colors.carpYellow } },
                { "packerSuccess", { fg = colors.autumnGreen, bg = "NONE" } },
                { "NeoTreeNormal", { bg = colors.sumiInk1 } },
                { "NeoTreeNormalNC", { bg = colors.sumiInk1 } },
                { "NoiceCmdlineIconCmdline", { fg = colors.oniViolet } },
                { "NoiceCmdlinePopupBorderCmdline", { fg = colors.oniViolet } },
                { "NoiceCmdlineIconFilter", { fg = colors.springGreen } },
                { "NoiceCmdlinePopupBorderFilter", { fg = colors.springGreen } },
                { "NoiceCmdLineIconLua", { fg = colors.crystalBlue } },
                { "NoiceCmdlinePopupBorderLua", { fg = colors.crystalBlue } },
                { "NoiceCmdlineIconHelp", { fg = colors.surimiOrange } },
                { "NoiceCmdlinePopupBorderHelp", { fg = colors.surimiOrange } },
                { "NoiceCmdLineIconSearch", { fg = colors.roninYellow } },
                { "NoiceCmdlinePopupBorderSearch", { fg = colors.roninYellow } },
                { "NoiceCmdlineIconIncRename", { fg = colors.peachRed } },
                { "NoiceCmdlinePopupdBorderIncRename", { fg = colors.peachRed } },
                { "NoiceMini", { bg = colors.sumiInk4 } },
                { "NoiceLspProgressClient", { fg = colors.oniViolet, bold = true } },
                { "Folded", { bg = colors.winterBlue } },
                { "TSRainbowRed", { fg = colors.peachRed } },
                { "TSRainbowYellow", { fg = colors.carpYellow } },
                { "TSRainbowBlue", { fg = colors.crystalBlue } },
                { "TSRainbowGreen", { fg = colors.springGreen } },
                { "TSRainbowViolet", { fg = colors.oniViolet } },
                { "TSRainbowCyan", { fg = colors.lightBlue } },
                { "TreesitterContext", { bg = colors.sumiInk0 } },
                { "FloatTitle", { bg = "NONE" } },
                { "DiffviewFilePanelTitle", { fg = colors.crystalBlue } },
                {
                    "DiffviewDiffDeleteDim",
                    {
                        fg = function()
                            return get_hl("Comment")().fg
                        end,
                    },
                },
                { "LspInlayHint", { fg = colors.springViolet2, bg = colors.winterBlue } },
                { "@text", { fg = colors.fujiWhite } },
                { "RainbowDelimiterRed", { fg = colors.peachRed } },
                { "RainbowDelimiterYellow", { fg = colors.autumnYellow } },
                { "RainbowDelimiterBlue", { fg = colors.crystalBlue } },
                { "RainbowDelimiterOrange", { fg = colors.surimiOrange } },
                { "RainbowDelimiterGreen", { fg = colors.waveAqua1 } },
                { "RainbowDelimiterViolet", { fg = colors.oniViolet } },
                { "RainbowDelimiterCyan", { fg = colors.lightBlue } },
                { "NotifyERRORBorder", { link = "NvimNotifyError" } },
                { "NotifyERRORIcon", { link = "NvimNotifyError" } },
                { "NotifyERRORTitle", { link = "NvimNotifyError" } },
                { "NotifyWARNBorder", { link = "NvimNotifyWarn" } },
                { "NotifyWARNIcon", { link = "NvimNotifyWarn" } },
                { "NotifyWARNTitle", { link = "NvimNotifyWarn" } },
                { "NotifyINFOBorder", { link = "NvimNotifyInfo" } },
                { "NotifyINFOIcon", { link = "NvimNotifyInfo" } },
                { "NotifyINFOTitle", { link = "NvimNotifyInfo" } },
                { "NotifyDEBUGBorder", { link = "NvimNotifyDebug" } },
                { "NotifyDEBUGIcon", { link = "NvimNotifyDebug" } },
                { "NotifyDEBUGTitle", { link = "NvimNotifyDebug" } },
                { "NotifyTRACEBorder", { link = "NvimNotifyTrace" } },
                { "NotifyTRACEIcon", { link = "NvimNotifyTrace" } },
                { "NotifyTRACETitle", { link = "NvimNotifyTrace" } },
                { "NotificationInfo", { link = "NvimNotifyInfo" } },
                { "NotificationWarning", { link = "NvimNotifyWarn" } },
                { "NotificationError", { link = "NvimNotifyError" } },

                {
                    "@comment.warning.gitcommit",
                    {
                        undercurl = true,
                        sp = function()
                            return get_hl("@comment.warning")().bg
                        end,
                        nocombine = true,
                    },
                },

                -- LSP hls
                { "@lsp.typemod.variable.global", { fg = colors.lightBlue } },

                -- Markup specific
                { "@markup.raw", { fg = colors.springViolet2, bg = colors.sumiInk1 } },
                { "@markup.raw.block", select_hl("@markup.raw", { "fg" }) },
                { "@markup.raw.delimiter", { link = "@punctuation.delimiter" } },
                {
                    "CodeBlock",
                    function()
                        return { bg = get_hl("@markup.raw")().bg }
                    end,
                },
                { "Headline", { bg = colors.sumiInk0 } },
                { "@markup.list", { fg = colors.crystalBlue } },
                { "@markup.list.number", { fg = colors.surimiOrange } },
                { "@markup.list.checked", { fg = colors.springGreen } },
                { "@markup.list.indeterminate", { fg = colors.carpYellow } },
                { "@markup.verbatim", { fg = colors.springGreen, bg = colors.sumiInk0 } },
                { "@org.tag.body", { fg = colors.waveAqua2, italic = true } },
                { "@org.tag.delimiter", { link = "@punctuation.delimiter" } },
                { "@org.verbatim", { link = "@markup.verbatim" } },
                {
                    "@org.verbatim.delimiter",
                    {
                        fg = function()
                            return get_hl("@markup.raw.delimiter")().fg
                        end,
                        bg = function()
                            return get_hl("@org.verbatim")().bg
                        end,
                    },
                },
                { "@org.code", { link = "@markup.raw" } },
                {
                    "@org.code.delimiter",
                    {
                        fg = function()
                            return get_hl("@markup.raw.delimiter")().fg
                        end,
                        bg = function()
                            return get_hl("@org.code")().bg
                        end,
                    },
                },
                { "@org.italic.delimiter", get_hl("@markup.raw.delimiter", { italic = true }) },
                { "@org.bold.delimiter", get_hl("@markup.raw.delimiter", { bold = true }) },
                { "@org.strikethrough.delimiter", get_hl("@markup.raw.delimiter", { strikethrough = true }) },
                { "@org.timestamp.active", { fg = colors.springViolet1, underline = true } },
                {
                    "@org.timestamp.active.delimiter",
                    get_hl("@org.timestamp.active", { underline = false, nocombine = true }),
                },
                { "@org.timestamp.inactive", { fg = colors.springViolet2 } },
                {
                    "@org.timestamp.inactive.delimiter",
                    get_hl("@org.timestamp.inactive"),
                },
                { "@org.keyword.done", { fg = colors.springGreen, bold = true, italic = true } },
                { "@org.keyword.todo", { fg = colors.samuraiRed, bold = true, italic = true } },
                {
                    "@org.priority.highest",
                    { fg = colors.samuraiRed, bg = "#fabebe", nocombine = true, underdouble = true, bold = true },
                },
                {
                    "@org.priority.default",
                    { fg = "#fa7f02", bg = "#fcd99a", nocombine = true, underline = true, bold = true },
                },
                {
                    "@org.priority.lowest",
                    { fg = colors.fujiWhite, bg = colors.fujiGray, nocombine = true, underline = true, bold = true },
                },
                {
                    "@org.agenda.scheduled_past",
                    {
                        fg = colors.springViolet2,
                        italic = true,
                    },
                },
                {
                    "@org.agenda.deadline",
                    {
                        fg = colors.waveRed,
                    },
                },
                { "@org.agenda.day", { fg = colors.oniViolet, bold = true, underdouble = true } },
                { "@org.agenda.today", { fg = colors.springBlue, bold = true, underdouble = true } },

                -- Titles/Headlines
                { "@markup.heading.1", { fg = colors.crystalBlue, bold = true } },
                { "@markup.heading.2", { fg = colors.carpYellow, bold = true } },
                { "@markup.heading.3", { fg = colors.peachRed, bold = true } },
                { "@markup.heading.4", { fg = colors.surimiOrange, bold = true } },
                { "@markup.heading.5", { fg = colors.oniViolet2, bold = true } },
                { "@markup.heading.6", { fg = colors.sakuraPink, bold = true } },
                { "@markup.heading.7", { fg = colors.lightBlue, bold = true } },
                { "@markup.heading.8", { fg = colors.springGreen, bold = true } },
                { "@org.headline.level1", { link = "@markup.heading.1" } },
                { "@org.headline.level2", { link = "@markup.heading.2" } },
                { "@org.headline.level3", { link = "@markup.heading.3" } },
                { "@org.headline.level4", { link = "@markup.heading.4" } },
                { "@org.headline.level5", { link = "@markup.heading.5" } },
                { "@org.headline.level6", { link = "@markup.heading.6" } },
                { "@org.headline.level7", { link = "@markup.heading.7" } },
                { "@org.headline.level8", { link = "@markup.heading.8" } },
                { "@markup.heading.1.marker", { link = "@markup.heading.1" } },
                { "@markup.heading.2.marker", { link = "@markup.heading.2" } },
                { "@markup.heading.3.marker", { link = "@markup.heading.3" } },
                { "@markup.heading.4.marker", { link = "@markup.heading.4" } },
                { "@markup.heading.5.marker", { link = "@markup.heading.5" } },
                { "@markup.heading.6.marker", { link = "@markup.heading.6" } },
                { "@markup.heading.7.marker", { link = "@markup.heading.7" } },
                { "@markup.heading.8.marker", { link = "@markup.heading.8" } },
                { "@markup.quote", { fg = colors.oldWhite }},

                -- For Visual Whitespace plugin
                { "visual-whitespace", get_hl("Visual", { fg = colors.fujiGray }) },
                -- Better hl for latex fragments in org files
                { "texMathZoneX", { fg = colors.surimiOrange } },
                -- Use underlines for urls
                { "@string.special.url", get_hl("@string.special.url", { underline = true, undercurl = false }) },
            }

            if vim.g.neovide then
                table.insert(extra_hls, 1, { "Normal", { fg = colors.fujiWhite, bg = "#1a1c2b" } })
            end

            vim.iter(extra_hls):enumerate():fold({}, function(t, index, tbl)
                local hl_name = tbl[1]
                local hl_opts = tbl[2]
                local wrapper = function()
                    if t[hl_name] then
                        vim.notify(
                            string.format("Duplicate highlight '%s' defined at index '%d'!", hl_name, index),
                            vim.log.levels.ERROR
                        )
                    end

                    if type(hl_opts) == "function" then
                        hl_opts = hl_opts()
                    end
                    hl_opts = vim.iter(hl_opts):fold({}, function(hl_t, k, v)
                        if type(v) == "function" then
                            v = v()
                        end
                        hl_t[k] = v
                        return hl_t
                    end)
                    if hl_opts.force == nil then
                        vim.tbl_deep_extend("force", hl_opts, { force = true })
                    end
                    vim.api.nvim_set_hl(0, hl_name, hl_opts)
                    t[hl_name] = true
                    return t
                end
                local success, result = pcall(wrapper)
                if not success then
                    vim.notify(
                        string.format(
                            "Failed to set highlight for '%s', err: '%s' ... Table:\n%s",
                            hl_name,
                            result,
                            vim.inspect(hl_opts)
                        ),
                        vim.log.levels.ERROR
                    )
                end
                return result
            end)
        end,
    },
}
