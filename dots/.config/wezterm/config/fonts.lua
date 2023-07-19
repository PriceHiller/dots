local wezterm = require("wezterm")

return {
    use_cap_height_to_scale_fallback_fonts = true,
    line_height = 1.0,
    font = wezterm.font_with_fallback({
        {
            family = "FiraCode Nerd Font",
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
        {
            family = "MesloLGS Nerd Font",
        },
        {
            family = "Noto Fonts Emoji",
        },
        { family = "Nerd Font Symbols" },
    }),
    font_size = 11,
}
