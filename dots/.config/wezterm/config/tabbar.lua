local wezterm = require("wezterm")
local color_names = require("config.theme.colors").color_names
local log = require("lib.log")

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

---@class Url See https://wezfurlong.org/wezterm/config/lua/wezterm.url/Url.html
---@field scheme "file" | "https" The URL scheme such as "file", or "https"
---@field file_path string Decodes the path field and interprets it as a file path
---@field username string The username portion of the URL, or an empty string if none is specified
---@field password string The password portion of the URL, or nil if none is specified
---@field host string The hostname portion of the URL, with IDNA decoded to UTF-8
---@field path string The path portion of the URL, complete with percent encoding
---@field fragment string The fragment portion of the URL
---@field query string The query portion of the URL

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    log.debug("received event", { prefix = "format-tab-title", ignore_result = true })

    local function tab_title(tab_info)
        local title = tab_info.tab_title
        -- if the tab title is explicitly set, take that
        if title and #title > 0 then
            return title
        end
        -- Otherwise, use the title from the active pane
        -- in that tab
        local active_pane = tab_info.active_pane
        ---@type Url
        local pane_cwd
        pane_cwd = tab_info.active_pane.current_working_dir
        if type(pane_cwd) == "userdata" then
            pane_cwd = pane_cwd.file_path:gsub(wezterm.home_dir, "~")
        end
        return string.format("%s %s", active_pane.title, pane_cwd or "")
    end

    local bg = color_names.kanagawa.sumiInk0
    local fg = color_names.kanagawa.sumiInk4

    local edge_bg = color_names.kanagawa.sumiInk0
    local edge_fg = color_names.kanagawa.oniViolet

    local title = tab_title(tab)
    if #title > max_width then
        title = " " .. wezterm.truncate_right(title, max_width - 6) .. "..."
    else
        title = " " .. title .. " "
    end

    if title:match("^%s+$") then
        title = "N/A"
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

wezterm.on("update-right-status", function(window, pane)
    log.debug("received event", { prefix = "update-status", ignore_result = true })
    -- Each element holds the text for a cell in a "powerline" style << fade

    -- Figure out the cwd and host of the current pane.
    -- This will pick up the hostname for the remote host if your
    -- shell is using OSC 7 on the remote host.
    ---@type Url
    local cwd_uri = pane:get_current_working_dir()
    local hostname = ""
    local cwd = ""
    if type(cwd_uri) == "userdata" then
        -- Running on a newer version of wezterm and we have
        -- a URL object here, making this simple!
        ---@diagnostic disable-next-line: undefined-field
        cwd = cwd_uri.file_path
        cwd = cwd:gsub(wezterm.home_dir, "~")
        ---@diagnostic disable-next-line: undefined-field
        hostname = cwd_uri.host or wezterm.hostname()
    end

    cwd = " " .. cwd
    if hostname ~= nil or hostname ~= "" then
        hostname = "@" .. hostname
    end

    local date = " " .. wezterm.strftime("%a, %b %-d, %I:%M %p")

    -- An entry for each battery (typically 0 or 1 battery)
    local battery = ""
    for _, b in ipairs(wezterm.battery_info()) do
        local charge_percent = b.state_of_charge * 100
        local battery_icon = "󰁹"

        if charge_percent < 100 then
            battery_icon = "󰁹"
        elseif charge_percent < 90 then
            battery_icon = "󰂂"
        elseif charge_percent < 80 then
            battery_icon = "󰂁"
        elseif charge_percent < 70 then
            battery_icon = "󰂀"
        elseif charge_percent < 60 then
            battery_icon = "󰁿"
        elseif charge_percent < 50 then
            battery_icon = "󰁾"
        elseif charge_percent < 40 then
            battery_icon = "󰁽"
        elseif charge_percent < 30 then
            battery_icon = "󰁼"
        elseif charge_percent < 20 then
            battery_icon = "󰁻"
        elseif charge_percent < 10 then
            battery_icon = "󰁺"
        end

        battery = battery_icon .. " " .. string.format("%.0f%%", charge_percent)
    end

    local leader_text = "󰀘 LEADER"
    local leader = ""
    if window:leader_is_active() then
        leader = leader_text
    end

    local key_table = window:active_key_table()
    if key_table then
        leader = leader_text
        key_table = "󰌌 " .. key_table:gsub("_", " "):gsub("(%l)(%w*)", function (a,b)
            return string.upper(a)..b
        end)
    end

    -- Color palette for the backgrounds of each cell
    local fade_colors = {
        { bg = color_names.kanagawa.roninYellow, fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.carpYellow, fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.springGreen, fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.crystalBlue, fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.oniViolet,   fg = color_names.kanagawa.sumiInk0 },
        { bg = color_names.kanagawa.waveRed,     fg = color_names.kanagawa.sumiInk0 },
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
        if text ~= nil and text ~= "" then
            table.insert(elements, { Text = " " .. text .. " " })
        end
        if not is_last then
            table.insert(elements, { Foreground = { Color = fade_colors[cell_no + 1].bg } })
            table.insert(elements, { Text = edges.solid.right })
        end
        num_cells = num_cells + 1
    end

    local cells = {
        leader,
        key_table,
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

return {
    enable_tab_bar = true,
    tab_bar_at_bottom = true,
    tab_max_width = 48,
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = false,
}
