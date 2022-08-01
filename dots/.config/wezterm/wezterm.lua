local wezterm = require("wezterm")
local wlib = require("wlib")

-- NOTE: Should be merged
-- NOTE: base configuration
local events = require("config.events")
local fonts = require("config.fonts")
local theme = require("config.theme.theme")
local tabbar = require("config.tabbar")
local rendering = require("config.rendering")
local keybinds = require("config.keybinds")
local misc = require("config.misc")

-- NOTE: Pull in the OS specific config, this is passed last to the mergeable
-- NOTE: as the last item to be merged (last item passed) overrides all others
local os_config_mod = "config.os." .. wlib.get_os_arch().name:lower()
wezterm.log_info("Loading os config from " .. os_config_mod)
local found, os_config = pcall(require, os_config_mod)
if not found then
    wezterm.log_warn("Could not load a os config from " .. os_config_mod)
    -- Empty out os_config if we can't find a valid configuration, won't
    -- override any settings
    os_config = {}
end

local config = wlib.Table.merge(events, fonts, theme, tabbar, misc, rendering, keybinds, os_config)
return config
