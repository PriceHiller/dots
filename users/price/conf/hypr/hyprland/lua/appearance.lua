local colors = require("colors")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 3,
        -- Hyprland's `col.active_border`/`col.inactive_border` keys contain
        -- a literal `.`, so they cannot be expressed as a Lua identifier.
        -- Use bracket-quoted keys to preserve the original keyword name.
        --
        -- In Lua mode, gradients (colour + angle) must be a table; the old
        -- hyprlang single-string form `"rgb(...) 45deg"` is not accepted.
        ["col.active_border"] = {
            colors = { "rgb(" .. colors.hex.surimiOrange .. ")" },
            angle = 45,
        },
        ["col.inactive_border"] = "rgb(" .. colors.hex.sumiInk6 .. ")",
    },

    decoration = {
        rounding = 6,
        rounding_power = 4.0,
        blur = {
            enabled = true,
            size = 8,
            passes = 1,
            noise = 0.025,
        },
        shadow = {
            enabled = true,
        },
        dim_special = 0.05,
    },
    misc = {
        enable_anr_dialog = false,
        disable_hyprland_logo = true,
        focus_on_activate = true,
        animate_manual_resizes = true,
    },

    input = {
        kb_options = "caps:escape",
    },
})

-- ---------------------------------------------------------------------------
-- Animations
-- ---------------------------------------------------------------------------

hl.curve("overshot", { type = "bezier", points = { { 0.08, 0.8 }, { 0, 1.1 } } })
hl.curve("quick_curve", { type = "bezier", points = { { 0, 0.5 }, { 0, 0.5 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })
