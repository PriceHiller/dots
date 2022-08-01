local wezterm = require("wezterm")

wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
    local scrollback_lines = require("config.misc").scrollback_lines
    local scrollback = pane:get_lines_as_text(scrollback_lines)
    local name = os.tmpname()
    local f = io.open(name, "w+")
    f:write(scrollback)
    f:flush()
    f:close()
    window:perform_action(wezterm.action({ SpawnCommandInNewTab = { args = { "nvim", name } } }), pane)

    wezterm.sleep_ms(1000)
    os.remove(name)
end)

return {}
