vim.opt.fillchars:append({
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vert = "│",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
})

require("kanagawa").setup({
    transparent = true,
    dim_inactive = true,
    globalStatus = true,
    theme = "dragon",
    colors = {
        theme = {
            all = {
                ui = {
                    bg_gutter = "NONE",
                },
            },
        },
    },
    overrides = function(palette)
        local colors = palette.palette
        vim.api.nvim_set_hl(0, "NvimNotifyError", { fg = colors.samuraiRed })
        vim.api.nvim_set_hl(0, "NvimNotifyWarn", { fg = colors.roninYellow })
        vim.api.nvim_set_hl(0, "NvimNotifyInfo", { fg = colors.springGreen })
        vim.api.nvim_set_hl(0, "NvimNotifyDebug", { fg = colors.crystalBlue })
        vim.api.nvim_set_hl(0, "NvimNotifyTrace", { fg = colors.oniViolet })

        local overrides = {
            DiffAdd = { bg = colors.winterGreen, fg = colors.autumnGreen },
            DiffDelete = { bg = colors.winterREd, fg = colors.autumnRed },
            NeogitPopupSectionTitle = { fg = colors.crystalBlue },
            NeogitPopupConfigEnabled = { fg = colors.springBlue, italic = true },
            NeogitPopupActionkey = { fg = colors.surimiOrange },
            NeogitPopupConfigKey = { fg = colors.peachRed },
            NeogitHunkHeader = { fg = colors.crystalBlue, bg = colors.sumiInk2 },
            NeogitHunkHeaderHighlight = { fg = colors.roninYellow, bg = colors.sumiInk1 },
            NeogitBranch = { fg = colors.autumnYellow, bold = true },
            NeogitUnmergedInto = { fg = colors.surimiOrange, bold = true },
            NeogitRemote = { fg = colors.carpYellow, bold = true },
            NeogitDiffContext = { bg = colors.sumiInk3 },
            NeogitDiffContextHighlight = { bg = colors.sumiInk4 },
            NeogitCursorLine = { link = "CursorLine" },
            NeogitDiffDelete = { link = "DiffDelete" },
            NeogitDiffDeleteHighlight = { link = "DiffDelete" },
            NeogitDiffHeader = { fg = colors.oniViolet, bg = colors.sumiInk0, bold = true },
            NeogitDiffHeaderHighlight = { fg = colors.sakuraPink, bg = colors.sumiInk0, bold = true },
            NeogitDiffAdd = { link = "DiffAdd" },
            NeogitDiffAddHighlight = { link = "DiffAdd" },
            NeogitStagedChanges = { fg = colors.surimiOrange, bold = true },
            NeogitUnpulledChanges = { fg = colors.peachRed, bold = true },
            NeogitUnmergedChanges = { fg = colors.springGreen, bold = true },
            NeogitUnstagedChanges = { fg = colors.peachRed, bold = true },
            NeogitUntrackedFiles = { fg = colors.peachRed, bold = true },
            NeogitRecentCommits = { fg = colors.crystalBlue, bold = true },
            NeogitCommitViewHeader = { fg = colors.crystalBlue, bold = true, italic = true },
            NeogitFilePath = { fg = colors.autumnYellow, italic = true },
            NeogitNotificationInfo = { fg = colors.springGreen, bold = true },
            NeogitNotificationWarning = { fg = colors.roninYellow, bold = true },
            NeogitNotificationError = { fg = colors.samuraiRed, bold = true },
            menuSel = { bg = colors.sumiInk0, fg = "NONE" },
            Pmenu = { fg = colors.fujiWhite, bg = colors.sumiInk2 },
            CmpItemAbbrDeprecated = { fg = colors.fujiGray, bg = "NONE" },
            CmpItemAbbrMatch = { fg = colors.crystalBlue, bg = "NONE" },
            CmpItemAbbrMatchFuzzy = { fg = colors.crystalBlue, bg = "NONE" },
            CmpItemMenu = { fg = colors.roninYellow, bg = "NONE" },
            CmpItemKindField = { fg = colors.fujiWhite, bg = colors.sakuraPink },
            CmpItemKindProperty = { fg = colors.fujiWhite, bg = colors.sakuraPink },
            CmpItemKindEvent = { fg = colors.fujiWhite, bg = colors.sakuraPink },
            CmpItemKindText = { fg = colors.fujiWhite, bg = colors.dragonBlue },
            CmpItemKindEnum = { fg = colors.fujiWhite, bg = colors.crystalBlue },
            CmpItemKindKeyword = { fg = colors.fujiWhite, bg = colors.springBlue },
            CmpItemKindConstant = { fg = colors.fujiWhite, bg = colors.crystalBlue },
            CmpItemKindConstructor = { fg = colors.fujiWhite, bg = colors.crystalBlue },
            CmpItemKindReference = { fg = colors.fujiWhite, bg = colors.crystalBlue },
            CmpItemKindFunction = { fg = colors.fujiWhite, bg = colors.oniViolet },
            CmpItemKindStruct = { fg = colors.fujiWhite, bg = colors.oniViolet },
            CmpItemKindClass = { fg = colors.fujiWhite, bg = colors.oniViolet },
            CmpItemKindModule = { fg = colors.fujiWhite, bg = colors.oniViolet },
            CmpItemKindOperator = { fg = colors.fujiWhite, bg = colors.oniViolet },
            CmpItemKindVariable = { fg = colors.fujiWhite, bg = colors.roninYellow },
            CmpItemKindFile = { fg = colors.fujiWhite, bg = colors.autumnYellow },
            CmpItemKindUnit = { fg = colors.fujiWhite, bg = colors.autumnYellow },
            CmpItemKindSnippet = { fg = colors.fujiWhite, bg = colors.autumnYellow },
            CmpItemKindFolder = { fg = colors.fujiWhite, bg = colors.autumnYellow },
            CmpItemKindMethod = { fg = colors.fujiWhite, bg = colors.autumnGreen },
            CmpItemKindValue = { fg = colors.fujiWhite, bg = colors.autumnGreen },
            CmpItemKindEnumMember = { fg = colors.fujiWhite, bg = colors.autumnGreen },
            CmpItemKindInterface = { fg = colors.fujiWhite, bg = colors.waveRed },
            CmpItemKindColor = { fg = colors.fujiWhite, bg = colors.waveAqua2 },
            CmpItemKindTypeParameter = { fg = colors.fujiWhite, bg = colors.waveAqua2 },
            CmpCustomSelectionGit = { fg = colors.fujiWhite, bg = colors.roninYellow },
            CmpCustomSelectionBuffer = { fg = colors.fujiWhite, bg = colors.dragonBlue },
            CmpCustomSelectionPath = { fg = colors.fujiWhite, bg = colors.autumnYellow },
            CmpCustomSelectionCalculator = { fg = colors.fujiWhite, bg = colors.waveBlue2 },
            CmpCustomSelectionNeorg = { fg = colors.fujiWhite, bg = colors.waveAqua1 },
            CmpCustomSelectionEmoji = { fg = colors.fujiWhite, bg = colors.dragonBlue },
            CmpCustomSelectionZsh = { fg = colors.fujiWhite, bg = colors.springGreen },
            CmpCustomSelectionCrates = { fg = colors.fujiWhite, bg = colors.roninYellow },
            CmpCustomSelectionCmdHistory = { fg = colors.fujiWhite, bg = colors.waveBlue2 },
            CmpCustomSelectionRipgrep = { fg = colors.fujiWhite, bg = colors.dragonBlue },
            CmpCustomSelectionNpm = { fg = colors.fujiWhite, bg = colors.peachRed },
            CmpCustomSelectionCommit = { fg = colors.fujiWhite, bg = colors.peachRed },
            CmpCustomSelectionSpell = { fg = colors.fujiWhite, bg = colors.waveRed },
            TelescopeNormal = { bg = colors.sumiInk2 },
            TelescopeBorder = { bg = colors.sumiInk2, fg = colors.sumiInk1 },
            TelescopePromptBorder = { bg = colors.sumiInk0, fg = colors.sumiInk0 },
            TelescopePromptNormal = { bg = colors.sumiInk0, fg = colors.fujiWhite },
            TelescopePromptTitle = { fg = colors.sumiInk0, bg = colors.oniViolet },
            TelescopePreviewTitle = { fg = colors.sumiInk0, bg = colors.sakuraPink },
            TelescopePreviewNormal = { bg = colors.sumiInk4 },
            TelescopePreviewBorder = { link = "TelescopePreviewNormal" },
            TelescopeResultsTitle = { fg = "NONE", bg = "NONE" },
            WinSeparator = { fg = colors.sumiInk4, bg = "NONE" },
            MiniCursorword = { bg = colors.waveBlue2 },
            MiniCursorwordCurrent = { bg = colors.waveBlue2 },
            rainbowcol1 = { fg = colors.oniViolet },
            rainbowcol2 = { fg = colors.crystalBlue },
            rainbowcol3 = { fg = colors.lightBlue },
            rainbowcol4 = { fg = colors.sakuraPink },
            rainbowcol5 = { fg = colors.springGreen },
            rainbowcol6 = { fg = colors.springViolet2 },
            rainbowcol7 = { fg = colors.carpYellow },
            packerSuccess = { fg = colors.autumnGreen, bg = "NONE" },
            WinBar = { fg = colors.fujiWhite, bg = colors.sumiInk1 },
            WinBarNC = { fg = colors.fujiWhite, bg = colors.sumiInk1 },
            NeoTreeNormal = { bg = colors.sumiInk1 },
            NeoTreeNormalNC = { bg = colors.sumiInk1 },
            NoiceCmdlineIconCmdline = { fg = colors.oniViolet },
            NoiceCmdlinePopupBorderCmdline = { fg = colors.oniViolet },
            NoiceCmdlineIconFilter = { fg = colors.springGreen },
            NoiceCmdlinePopupBorderFilter = { fg = colors.springGreen },
            NoiceCmdLineIconLua = { fg = colors.crystalBlue },
            NoiceCmdlinePopupBorderLua = { fg = colors.crystalBlue },
            NoiceCmdlineIconHelp = { fg = colors.surimiOrange },
            NoiceCmdlinePopupBorderHelp = { fg = colors.surimiOrange },
            NoiceCmdLineIconSearch = { fg = colors.roninYellow },
            NoiceCmdlinePopupBorderSearch = { fg = colors.roninYellow },
            NoiceCmdlineIconIncRename = { fg = colors.peachRed },
            NoiceCmdlinePopupdBorderIncRename = { fg = colors.peachRed },
            NoiceMini = { bg = colors.sumiInk4 },
            NoiceLspProgressClient = { fg = colors.oniViolet, bold = true },
            Folded = { bg = colors.waveBlue1 },
            UfoFoldedBg = { bg = colors.waveBlue1 },
            TSRainbowRed = { fg = colors.peachRed },
            TSRainbowYellow = { fg = colors.carpYellow },
            TSRainbowBlue = { fg = colors.crystalBlue },
            TSRainbowGreen = { fg = colors.springGreen },
            TSRainbowViolet = { fg = colors.oniViolet },
            TSRainbowCyan = { fg = colors.lightBlue },
            SmoothCursorCursor = { fg = colors.roninYellow },
            SmoothCursorTrailBig1 = { fg = colors.autumnYellow },
            SmoothCursorTrailBig2 = { fg = colors.crystalBlue },
            SmoothCursorTrailMedium = { fg = colors.oniViolet },
            SmoothCursorTrailSmall = { fg = colors.springBlue },
            SmoothCursorTrailXSmall = { fg = colors.waveAqua2 },
            TreesitterContext = { bg = colors.sumiInk0 },
            FloatTitle = { bg = "NONE" },
            DiffviewFilePanelTitle = { fg = colors.crystalBlue },
            Headline = { bg = colors.sumiInk2 },
            HeadlineReversed = { bg = colors.sumiInk1 },
            LspInlayHint = { link = "Comment", italic = true },
            ["@text.title.1.marker.markdown"] = { fg = colors.surimiOrange },
            ["@text.title.2.marker.markdown"] = { fg = colors.surimiOrange },
            ["@text.title.3.marker.markdown"] = { fg = colors.surimiOrange },
            ["@text.title.4.marker.markdown"] = { fg = colors.surimiOrange },
            ["@text.title.5.marker.markdown"] = { fg = colors.surimiOrange },
            ["@text.title.6.marker.markdown"] = { fg = colors.surimiOrange },
            RainbowDelimiterRed = { fg = colors.peachRed },
            RainbowDelimiterYellow = { fg = colors.autumnYellow },
            RainbowDelimiterBlue = { fg = colors.crystalBlue },
            RainbowDelimiterOrange = { fg = colors.surimiOrange },
            RainbowDelimiterGreen = { fg = colors.springGreen },
            RainbowDelimiterViolet = { fg = colors.oniViolet },
            RainbowDelimiterCyan = { fg = colors.lightBlue },
            NotifyERRORBorder = { link = "NvimNotifyError" },
            NotifyERRORIcon = { link = "NvimNotifyError" },
            NotifyERRORTitle = { link = "NvimNotifyError" },
            NotifyWARNBorder = { link = "NvimNotifyWarn" },
            NotifyWARNIcon = { link = "NvimNotifyWarn" },
            NotifyWARNTitle = { link = "NvimNotifyWarn" },
            NotifyINFOBorder = { link = "NvimNotifyInfo" },
            NotifyINFOIcon = { link = "NvimNotifyInfo" },
            NotifyINFOTitle = { link = "NvimNotifyInfo" },
            NotifyDEBUGBorder = { link = "NvimNotifyDebug" },
            NotifyDEBUGIcon = { link = "NvimNotifyDebug" },
            NotifyDEBUGTitle = { link = "NvimNotifyDebug" },
            NotifyTRACEBorder = { link = "NvimNotifyTrace" },
            NotifyTRACEIcon = { link = "NvimNotifyTrace" },
            NotifyTRACETitle = { link = "NvimNotifyTrace" },
        }

        return overrides
    end,
})
