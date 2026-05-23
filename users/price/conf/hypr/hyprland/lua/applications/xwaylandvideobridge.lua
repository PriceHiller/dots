-- Hide xwaylandvideobridge: zero-opacity, no animation, no focus, tiny size,
-- no blur. xwaylandvideobridge is a helper window that bridges screen sharing
-- to xwayland clients; it should be invisible in the layout.
local xwvb = { class = "^(xwaylandvideobridge)$" }

hl.window_rule({ match = xwvb, opacity = "0.0 override" })
hl.window_rule({ match = xwvb, no_anim = true })
hl.window_rule({ match = xwvb, no_initial_focus = true })
hl.window_rule({ match = xwvb, max_size = { 1, 1 } })
hl.window_rule({ match = xwvb, no_blur = true })
