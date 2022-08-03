local wezterm = require("wezterm")
local lib = require("wlib")

return {
    -- use_cap_height_to_scale_fallback_fonts = true,
    unicode_version = 14,
    font = wezterm.font_with_fallback({
        {
            family = "JetBrains Mono",
            weight = "DemiBold",
        },
        -- NOTE: Attempt to resolve missing symbols etc.
        -- <built-in>, BuiltIn
        { family = "Symbols Nerd Font Mono", scale = 0.8 },
        "Noto Sans Symbols",
        "Noto Sans Symbols2",
        "PowerlineExtraSymbols",
        { family = "FiraCode NF", weight = "DemiBold", scale = 1.2 },
        "FiraCode NF",
        "MesloLGS NF",

        -- <built-in>, BuiltIn
        -- Assumed to have Emoji Presentation
        -- Pixel sizes: [128]
        "Noto Color Emoji",

        "Noto Sans Adlam Unjoined",
        "Unifont",

        -- <built-in>, BuiltIn
        "Last Resort High-Efficiency",
    }),
    font_dirs = {
        "fonts",
    },
    font_locator = "ConfigDirsOnly",
    font_size = 14,
}
