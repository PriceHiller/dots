local wezterm = require("wezterm") --[[@as Wezterm]]

return {
    font_dirs = {
        (os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share") .. "/fonts",
    },
    use_cap_height_to_scale_fallback_fonts = true,
    line_height = 1.0,
    font = wezterm.font_with_fallback({
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
            family = "MesloLGS Nerd Font",
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
    font_size = 13,
}
