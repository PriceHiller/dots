local colors = require("config.theme.colors")

return {
    window_decorations = "RESIZE",
    window_background_opacity = 0.8,
    text_background_opacity = 1.0,
    inactive_pane_hsb = {
        brightness = 0.75,
        hue = 1.0,
        saturation = 1.0,
    },
    colors = colors.theme,
    force_reverse_video_cursor = true,
    default_cursor_style = "SteadyBar",
}
