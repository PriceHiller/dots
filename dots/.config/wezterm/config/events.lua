local wezterm = require("wezterm")

wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
    local scrollback_lines = require("config.misc").scrollback_lines
    local scrollback = pane:get_lines_as_text(scrollback_lines)
    local name = os.tmpname()
    local f = io.open(name, "w+")
    if f == nil then
        window:toast_notification("Wezterm", "Unable to get scrollback!", nil, 4000)
        return
    end
    f:write(scrollback)
    f:flush()
    f:close()
    window:perform_action(
        wezterm.action({ SpawnCommandInNewTab = { args = { "nvim", name, "+$", "-R", "+set filetype=termhistory" } } }),
        pane
    )

    wezterm.sleep_ms(1000)
    os.remove(name)
end)

return {}
