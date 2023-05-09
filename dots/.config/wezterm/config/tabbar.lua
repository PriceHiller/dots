local wezterm = require("wezterm")
local color_names = require("config.theme.colors").color_names


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


return {
    enable_tab_bar = true,
    tab_bar_at_bottom = true,
    tab_max_width = 48,
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = false
}
