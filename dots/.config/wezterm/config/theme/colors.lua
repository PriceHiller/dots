local wezterm = require("wezterm")
local M = {}

local color_names = {
    kanagawa = {
        fujiWhite = "#DCD7BA",
        oldWhite = "#C8C093",
        sumiInk0 = "#16161D",
        sumiInk1 = "#1F1F28",
        sumiInk2 = "#2A2A37",
        sumiInk3 = "#363646",
        sumiInk4 = "#54546D",
        waveBlue1 = "#223249",
        waveBlue2 = "#2D4F67",
        winterGreen = "#2B3328",
        winterYellow = "#49443C",
        winterRed = "#43242B",
        winterBlue = "#252535",
        autumnGreen = "#76946A",
        autumnRed = "#C34043",
        autumnYellow = "#DCA561",
        samuraiRed = "#E82424",
        roninYellow = "#FF9E3B",
        waveAqua1 = "#6A9589",
        dragonBlue = "#658594",
        fujiGray = "#727169",
        springViolet1 = "#938AA9",
        oniViolet = "#957FB8",
        crystalBlue = "#7E9CD8",
        springViolet2 = "#9CABCA",
        springBlue = "#7FB4CA",
        lightBlue = "#A3D4D5",
        waveAqua2 = "#7AA89F",
        springGreen = "#98BB6C",
        boatYellow1 = "#938056",
        boatYellow2 = "#C0A36E",
        carpYellow = "#E6C384",
        sakuraPink = "#D27E99",
        waveRed = "#E46876",
        peachRed = "#FF5D62",
        surimiOrange = "#FFA066",
    },
}

M.color_names = color_names

local colors = {
    tokyonight_night = {
        foreground = "#c0caf5",
        background = "#0f111d",
        cursor_bg = "#c0caf5",
        cursor_border = "#c0caf5",
        cursor_fg = "#1a1b26",
        selection_bg = "#33467C",
        selection_fg = "#c0caf5",
        ansi = { "#15161E", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#a9b1d6" },
        brights = { "#414868", "#f7768e", "#9ece6a", "#e0af68", "#7aa2f7", "#bb9af7", "#7dcfff", "#c0caf5" },
    },

    kanagawa = {
        foreground = color_names.kanagawa.fujiWhite,
        background = color_names.kanagawa.sumiInk0,

        cursor_bg = color_names.kanagawa.oldWhite,
        cursor_fg = color_names.kanagawa.oldWhite,
        cursor_border = color_names.kanagawa.oldWhite,

        selection_fg = color_names.kanagawa.oldWhite,
        selection_bg = color_names.kanagawa.waveBlue2,

        scrollbar_thumb = color_names.kanagawa.sumiInk0,
        split = color_names.kanagawa.sumiInk0,

        compose_cursor = color_names.kanagawa.roninYellow,

        ansi = {
            color_names.kanagawa.sumiInk0,
            color_names.kanagawa.autumnRed,
            color_names.kanagawa.autumnGreen,
            color_names.kanagawa.boatYellow2,
            color_names.kanagawa.crystalBlue,
            color_names.kanagawa.oniViolet,
            color_names.kanagawa.waveAqua1,
            color_names.kanagawa.oldWhite,
        },
        brights = {
            color_names.kanagawa.fujiGray,
            color_names.kanagawa.samuraiRed,
            color_names.kanagawa.springGreen,
            color_names.kanagawa.carpYellow,
            color_names.kanagawa.springBlue,
            color_names.kanagawa.springViolet1,
            color_names.kanagawa.waveAqua2,
            color_names.kanagawa.fujiWhite,
        },
        indexed = { [16] = color_names.kanagawa.surimiOrange, [17] = color_names.kanagawa.peachRed },
        tab_bar = {
            background = color_names.kanagawa.sumiInk0,

            inactive_tab_edge = color_names.kanagawa.sumiInk1,

            inactive_tab = {
                bg_color = color_names.kanagawa.sumiInk0,
                fg_color = color_names.kanagawa.sumiInk4,
            },

            inactive_tab_hover = {
                bg_color = color_names.kanagawa.sumiInk1,
                fg_color = color_names.kanagawa.sakuraPink,
            },
            new_tab = {
                bg_color = color_names.kanagawa.sumiInk0,
                fg_color = color_names.kanagawa.oniViolet,
            },

            new_tab_hover = {
                bg_color = color_names.kanagawa.sumiInk0,
                fg_color = color_names.kanagawa.peachRed,
            },
        },
    },
}
M.theme = colors.kanagawa

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.

local edges = {
    solid = {
        left = "",
        right = "",
    },
    empty = {
        left = "",
        right = "",
    },
}

return M
