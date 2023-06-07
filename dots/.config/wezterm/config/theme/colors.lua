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
        background = color_names.kanagawa.sumiInk1,

        cursor_bg = color_names.kanagawa.oldWhite,
        cursor_fg = color_names.kanagawa.oldWhite,
        cursor_border = color_names.kanagawa.oldWhite,

        selection_fg = color_names.kanagawa.oldWhite,
        selection_bg = color_names.kanagawa.waveBlue2,

        scrollbar_thumb = color_names.kanagawa.sumiInk0,
        split = color_names.kanagawa.sumiInk0,

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

---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local function tab_title(tab_info)
        local title = tab_info.tab_title
        -- if the tab title is explicitly set, take that
        if title and #title > 0 then
            return title
        end
        -- Otherwise, use the title from the active pane
        -- in that tab
        return tab_info.active_pane.title
    end

    local bg = color_names.kanagawa.sumiInk0
    local fg = color_names.kanagawa.sumiInk4

    local edge_bg = color_names.kanagawa.sumiInk0
    local edge_fg = color_names.kanagawa.oniViolet

    local title = " " .. wezterm.truncate_right(tab_title(tab), max_width - 2) .. " "

    if title:match("^%s+$") then
        title = " N/A "
    end

    if tab.is_active then
        bg = color_names.kanagawa.sumiInk0
        fg = color_names.kanagawa.oniViolet
    elseif hover then
        fg = color_names.kanagawa.peachRed
    end

    return {
        { Background = { Color = edge_bg } },
        { Foreground = { Color = edge_fg } },
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = title },
        { Background = { Color = edge_bg } },
        { Foreground = { Color = fg } },
        { Text = edges.empty.left },
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
    }
end)

wezterm.on("update-status", function(window, pane)
    -- Each element holds the text for a cell in a "powerline" style << fade

    -- Figure out the cwd and host of the current pane.
    -- This will pick up the hostname for the remote host if your
    -- shell is using OSC 7 on the remote host.
    local cwd_uri = pane:get_current_working_dir()
    local hostname = ""
    local cwd = ""
    if cwd_uri then
        cwd_uri = cwd_uri:sub(8)
        local slash = cwd_uri:find("/")
        if slash then
            hostname = cwd_uri:sub(1, slash - 1)
            -- Remove the domain name portion of the hostname
            local dot = hostname:find("[.]")
            if dot then
                hostname = hostname:sub(1, dot - 1)
            end
            hostname = "@" .. hostname
            -- and extract the cwd from the uri
            cwd = cwd_uri:sub(slash)
        end
    end

    cwd = " " .. cwd

    local date = " " .. wezterm.strftime("%a, %b %-d, %I:%M %p")

    -- An entry for each battery (typically 0 or 1 battery)
    local battery = ""
    for _, b in ipairs(wezterm.battery_info()) do
        local charge_percent = b.state_of_charge * 100
        local battery_icon = ""

        if charge_percent < 100 then
            battery_icon = ""
        elseif charge_percent < 70 then
            battery_icon = ""
        elseif charge_percent < 60 then
            battery_icon = ""
        elseif charge_percent < 50 then
            battery_icon = ""
        elseif charge_percent < 40 then
            battery_icon = ""
        elseif charge_percent < 30 then
            battery_icon = ""
        elseif charge_percent < 20 then
            battery_icon = ""
        elseif charge_percent < 10 then
            battery_icon = ""
        end

        battery = battery_icon .. " " .. string.format("%.0f%%", charge_percent)
    end

    -- Color palette for the backgrounds of each cell
    local fade_colors = {
        { bg = color_names.kanagawa.roninYellow, fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.springGreen, fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.crystalBlue, fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.oniViolet, fg = color_names.kanagawa.sumiInk0 },
    }

    -- The elements to be formatted
    local elements = {}
    -- Ensure the items have a "cap" on them
    table.insert(elements, { Foreground = { Color = fade_colors[1].bg } })
    table.insert(elements, { Text = edges.solid.right })

    -- How many cells have been formatted
    local num_cells = 0

    -- Translate a cell into elements
    local function push(text, is_last)
        local cell_no = num_cells + 1
        table.insert(elements, { Foreground = { Color = fade_colors[cell_no].fg } })
        table.insert(elements, { Background = { Color = fade_colors[cell_no].bg } })
        table.insert(elements, { Text = " " .. text .. " " })
        if not is_last then
            table.insert(elements, { Foreground = { Color = fade_colors[cell_no + 1].bg } })
            table.insert(elements, { Text = edges.solid.right })
        end
        num_cells = num_cells + 1
    end

    local cells = {
        cwd,
        battery,
        date,
        hostname,
    }
    while #cells > 0 do
        local cell = table.remove(cells, 1)
        push(cell, #cells == 0)
    end

    window:set_right_status(wezterm.format(elements))
end)

return M
