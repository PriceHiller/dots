local wezterm = require("wezterm")

return {
    use_cap_height_to_scale_fallback_fonts = true,
    line_height = 0.9,
    font = wezterm.font_with_fallback({
        {
            family = "FiraCodeNerdFont",
            weight = "Medium",
            harfbuzz_features = {
                "zero",
                "cv02",
                "cv30",
                "ss05",
                "ss03",
                "ss04",
                "cv26",
                "ss10",
            },
        },
        {
            family = "FiraCodeNerdFontMono",
            weight = "Medium",
            harfbuzz_features = {
                "zero",
                "cv02",
                "cv30",
                "ss05",
                "ss03",
                "ss04",
                "cv26",
                "ss10",
            },
        },
        {
            family = "JetBrains Mono",
            weight = "Medium",
        },
        -- NOTE: Attempt to resolve missing symbols etc.
        -- <built-in>, BuiltIn
        { family = "Symbols Nerd Font Mono" },
        { family = "Symbols Nerd Font" },
        "Noto Sans Symbols",
        "Noto Sans Symbols2",
        "PowerlineExtraSymbols",
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
    font_size = 11,
}
