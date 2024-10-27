local wezterm = require("wezterm")

return {
    font_dirs = {
        (os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share") .. "/fonts",
    },
    use_cap_height_to_scale_fallback_fonts = true,
    line_height = 1.0,
    font = wezterm.font_with_fallback({
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
        {
            family = "JetBrains Mono",
        },
        {
            family = "MesloLGS Nerd Font",
        },
        {
            family = "Twitter Color Emoji",
        },
        {
            family = "Noto Color Emoji",
        },
        { family = "Nerd Font Symbols" },
    }),
    font_size = 13,
}
