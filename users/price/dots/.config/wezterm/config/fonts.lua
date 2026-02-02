local wezterm = require("wezterm") --[[@as Wezterm]]

return {
    use_cap_height_to_scale_fallback_fonts = true,
    line_height = 1.0,
    font = wezterm.font_with_fallback({
        {
            family = "Maple Mono",
            harfbuzz_features = {
                "calt",
                "cv01",
                "cv02",
                "cv31",
                "ss07",
            },
        },
        ---@diagnostic disable-next-line: missing-fields
        {
            family = "Fira Code",
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
        ---@diagnostic disable-next-line: missing-fields
        {
            family = "JetBrains Mono",
        },
        ---@diagnostic disable-next-line: missing-fields
        {
            family = "Apple Color Emoji",
        },
        ---@diagnostic disable-next-line: missing-fields
        {
            family = "Twitter Color Emoji",
        },
        ---@diagnostic disable-next-line: missing-fields
        {
            family = "Noto Color Emoji",
        },
        ---@diagnostic disable-next-line: missing-fields
        { family = "Nerd Font Symbols" },
    }),
    font_size = 14,
}
