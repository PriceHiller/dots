local os = require("os")

local linux_config = {}

if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then
    linux_config.window_background_opacity = 0.70
end

return linux_config
