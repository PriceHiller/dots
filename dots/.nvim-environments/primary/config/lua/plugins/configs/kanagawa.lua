local colors = require("kanagawa.colors").setup({})
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
    overrides = {
        NeogitHunkHeader = { bg = colors.diff.text },
        NeogitHunkHeaderHighlight = { fg = colors.git.changed, bg = colors.diff.text },
        NeogitDiffContextHighlight = { bg = colors.diff.change },
        NeogitDiffDeleteHighlight = { fg = colors.git.removed, bg = colors.diff.delete },
        NeogitDiffAddHighlight = { fg = colors.git.added, bg = colors.diff.add },
        NeogitCommitViewHeader = { fg = colors.git.changed, bg = colors.diff.text },
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

        TelescopeNormal = { bg = colors.sumiInk1 },
        TelescopeBorder = { bg = colors.sumiInk1, fg = colors.sumiInk1 },
        TelescopePromptBorder = { bg = colors.sumiInk0, fg = colors.sumiInk0 },
        TelescopePromptTitle = { fg = colors.sumiInk0, bg = colors.oniViolet },
        TelescopePreviewTitle = { fg = colors.sumiInk0, bg = colors.sakuraPink },
        TelescopePreviewBorder = { bg = colors.sumiInk2, fg = colors.sumiInk2 },
        TelescopePreviewNormal = { bg = colors.sumiInk2 },
        TelescopeResultsTitle = { fg = "NONE", bg = "NONE" },

        WinSeparator = { fg = colors.sumiInk4, bg = "NONE" },

        MiniCursorword = { bg = colors.sumiInk3 },
        MiniCursorwordCurrent = { bg = colors.sumiInk3 },

        rainbowcol1 = { fg = colors.oniViolet },
        rainbowcol2 = { fg = colors.crystalBlue },
        rainbowcol3 = { fg = colors.lightBlue },
        rainbowcol4 = { fg = colors.sakuraPink },
        rainbowcol5 = { fg = colors.springGreen },
        rainbowcol6 = { fg = colors.springViolet2 },
        rainbowcol7 = { fg = colors.carpYellow },

        packerSuccess = { fg = colors.autumnGreen, bg = "NONE" },

        WinBar = { fg = colors.fujiWhite, bg = colors.sumiInk1b },
        WinBarNC = { fg = colors.fujiWhite, bg = colors.sumiInk1b },

        NeoTreeNormal = { bg = colors.sumiInk1b },
        NeoTreeNormalNC = { bg = colors.sumiInk1b },

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

        Folded = { bg = colors.winterBlue }
    },
})

-- NOTE: Colors for SmoothCursor
vim.api.nvim_set_hl(0, "SmoothCursorCursor", { fg = colors.roninYellow })
vim.api.nvim_set_hl(0, "SmoothCursorTrailBig1", { fg = colors.autumnYellow })
vim.api.nvim_set_hl(0, "SmoothCursorTrailBig2", { fg = colors.crystalBlue })
vim.api.nvim_set_hl(0, "SmoothCursorTrailMedium", { fg = colors.oniViolet })
vim.api.nvim_set_hl(0, "SmoothCursorTrailSmall", { fg = colors.springBlue })
vim.api.nvim_set_hl(0, "SmoothCursorTrailXSmall", { fg = colors.waveAqua2 })
