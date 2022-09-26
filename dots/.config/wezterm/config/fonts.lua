local wezterm = require("wezterm")
local lib = require("wlib")

return {
    use_cap_height_to_scale_fallback_fonts = true,
    unicode_version = 14,
    line_height = 0.9,
    font = wezterm.font_with_fallback({
        {
            family = "JetBrains Mono",
            weight = "DemiBold",
        },
        "PowerLineExtraSymbols",
        "Noto Color Emoji",
        "Symbols Nerd Font Mono",
        "Unifont",
        "Last Resort High-Efficiency",
    }),
    font_dirs = {
        "fonts",
    },
    font_locator = "ConfigDirsOnly",
    font_size = 11,
}
