if not hl.plugin.hyprcapture then
    return
end

local colors = require("colors")

hl.config({
    plugin = {
        ---@see https://github.com/gfhdhytghd/HyprCapture#configuration
        ---@see https://github.com/gfhdhytghd/HyprCapture#capture-options
        hyprcapture = {
            thumbnail_max_width = 800,
            thumbnail_max_height = 600,
            thumbnail_border_size = 2,
            screenshot_notification = false,
            ocr_mode = "text_layer",
            ocr_languages = "eng",
            ocr_engine = "tesseract",
            include_cursor = true,
            thumbnail_rounding = 4,
            thumbnail_border_color = "#" .. colors.hex.crystalBlue,
        },
    },
})

hl.bind("SUPER + SHIFT + 4", function()
    hl.plugin.hyprcapture.open("region", { clipboard = true })
end)
hl.bind("SUPER + SHIFT + 5", function()
    hl.plugin.hyprcapture.open_editor()
end)
