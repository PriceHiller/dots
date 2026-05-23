-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

--- Capture the currently focused monitor before any dispatch that might
--- change focus. Uses the native `hl.get_active_monitor()` so it is fast
--- (no shelling out via `hyprctl`, which would otherwise freeze input).
--- Returns the monitor's name (e.g. "DP-1") or nil.
local function focused_monitor_name()
    local mon = hl.get_active_monitor()
    return mon and mon.name or nil
end

--- Switch to workspace `ws` and ensure the workspace lives on the
--- previously-focused monitor. This mirrors the per-monitor workspace
--- semantics of the original bash scripts.
---
--- @param ws integer|string  workspace id or selector ("+1", "-1", etc.)
local function focus_ws_on_current_mon(ws)
    local mon = focused_monitor_name()
    hl.dispatch(hl.dsp.focus({ workspace = ws }))
    if mon then
        hl.dispatch(hl.dsp.workspace.move({ monitor = mon }))
    end
end

--- Move the active window to workspace `ws`, drag that workspace onto the
--- focused monitor, and optionally follow.
---
--- @param ws integer|string
--- @param follow boolean     when true, also focus the destination workspace
local function move_active_window_to_ws_on_current_mon(ws, follow)
    local mon = focused_monitor_name()
    hl.dispatch(hl.dsp.window.move({ workspace = ws, follow = false }))
    if mon then
        hl.dispatch(hl.dsp.workspace.move({ monitor = mon }))
    end
    if follow then
        hl.dispatch(hl.dsp.focus({ workspace = ws }))
    end
end

-- ---------------------------------------------------------------------------
-- Mouse
-- ---------------------------------------------------------------------------

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---------------------------------------------------------------------------
-- Submaps: resize / move_window
-- ---------------------------------------------------------------------------

hl.bind("SUPER + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
    hl.bind("left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

    hl.bind("l", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
    hl.bind("h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind("SUPER + M", hl.dsp.submap("move_window"))
hl.define_submap("move_window", function()
    hl.bind("right", hl.dsp.window.move({ direction = "r" }))
    hl.bind("left", hl.dsp.window.move({ direction = "l" }))
    hl.bind("up", hl.dsp.window.move({ direction = "u" }))
    hl.bind("down", hl.dsp.window.move({ direction = "d" }))

    hl.bind("l", hl.dsp.window.move({ direction = "r" }))
    hl.bind("h", hl.dsp.window.move({ direction = "l" }))
    hl.bind("k", hl.dsp.window.move({ direction = "u" }))
    hl.bind("j", hl.dsp.window.move({ direction = "d" }))

    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ---------------------------------------------------------------------------
-- Launchers / utilities
-- ---------------------------------------------------------------------------

hl.bind("ALT + v", hl.dsp.exec_cmd("rofi-cliphist"))
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("neovide --fork -- +term"))
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd("neovide --fork"))
hl.bind("SUPER + CTRL + RETURN", hl.dsp.exec_cmd("xdg-open 'http://'"))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + CTRL + SPACE", hl.dsp.exec_cmd("rofi -show window"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("swaync-client --hide-all"))
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("hyprlock"))

-- ---------------------------------------------------------------------------
-- Window management
-- ---------------------------------------------------------------------------

hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + Q", hl.dsp.window.kill())
-- Force kill (SIGKILL) the active window.
hl.bind("SUPER + CTRL + Q", function()
    hl.dispatch(hl.dsp.window.signal({ signal = 9 }))
end)
hl.bind("SUPER + A", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + M", hl.dsp.exit())

-- ---------------------------------------------------------------------------
-- Screen captures
-- ---------------------------------------------------------------------------

hl.bind("SUPER + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy --type image/png]]))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("screen-cap"))
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("screen-cap gif"))

-- ---------------------------------------------------------------------------
-- Media keys
-- ---------------------------------------------------------------------------
-- `locked = true`  → still fires while a lock-screen / input inhibitor is up.
-- `repeating = true` → repeats while held (volume / brightness).

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { repeating = true })

-- ---------------------------------------------------------------------------
-- Focus movement
-- ---------------------------------------------------------------------------

hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

-- ---------------------------------------------------------------------------
-- Workspaces
-- ---------------------------------------------------------------------------

-- SUPER + CTRL + arrow/hjkl: switch to prev/next absolute workspace, drag it
-- onto the current monitor.
for _, k in ipairs({ "left", "h" }) do
    hl.bind("SUPER + CTRL + " .. k, function()
        focus_ws_on_current_mon("-1")
    end)
end
for _, k in ipairs({ "right", "l" }) do
    hl.bind("SUPER + CTRL + " .. k, function()
        focus_ws_on_current_mon("+1")
    end)
end

-- SUPER + ALT + arrow/hjkl: send the active window to prev/next absolute
-- workspace, drag that workspace onto the current monitor, AND follow it
-- (matches the trailing `1` arg to `move-workspace-mon.bash`).
for _, k in ipairs({ "left", "h" }) do
    hl.bind("SUPER + ALT + " .. k, function()
        move_active_window_to_ws_on_current_mon("-1", true)
    end)
end
for _, k in ipairs({ "right", "l" }) do
    hl.bind("SUPER + ALT + " .. k, function()
        move_active_window_to_ws_on_current_mon("+1", true)
    end)
end

-- SUPER + CTRL + ALT + arrow/hjkl: as above, but silent (don't follow).
for _, k in ipairs({ "left", "h" }) do
    hl.bind("SUPER + CTRL + ALT + " .. k, function()
        move_active_window_to_ws_on_current_mon("-1", false)
    end)
end
for _, k in ipairs({ "right", "l" }) do
    hl.bind("SUPER + CTRL + ALT + " .. k, function()
        move_active_window_to_ws_on_current_mon("+1", false)
    end)
end

-- SUPER + 1..9: focus workspace N on the current monitor.
-- SUPER + CTRL + 1..9: silently move the active window to workspace N on the
-- current monitor.
for i = 1, 9 do
    hl.bind("SUPER + " .. i, function()
        focus_ws_on_current_mon(i)
    end)
    hl.bind("SUPER + CTRL + " .. i, function()
        move_active_window_to_ws_on_current_mon(i, false)
    end)
end
