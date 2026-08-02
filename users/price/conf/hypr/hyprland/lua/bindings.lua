local utils = require("utils")
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
    hl.dispatch(hl.dsp.window.move({ workspace = ws, follow = follow }))
    -- if mon then
    --     hl.dispatch(hl.dsp.workspace.move({ monitor = mon }))
    -- end
    -- if follow then
    --     hl.dispatch(hl.dsp.focus({ workspace = ws }))
    -- end
end

-- ---------------------------------------------------------------------------
-- Mouse
-- ---------------------------------------------------------------------------

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---------------------------------------------------------------------------
-- Submaps: resize / move_window
-- ---------------------------------------------------------------------------

hl.bind("SUPER + CTRL + R", hl.dsp.submap("resize"))
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
hl.bind("SUPER + CTRL + Q", hl.dsp.exec_cmd("hyprlock"))

-- ---------------------------------------------------------------------------
-- Window management
-- ---------------------------------------------------------------------------

hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + Q", hl.dsp.window.close())
-- Force kill (SIGKILL) the active window.
hl.bind("SUPER + ALT + X", hl.dsp.window.kill())
hl.bind("SUPER + CTRL + A", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())

-- ---------------------------------------------------------------------------
-- macOS-style SUPER shortcuts
-- ---------------------------------------------------------------------------
-- Super+C/V/X/Z/F behave like macOS Cmd+C/V/X/Z/F in GUI apps. In terminals (kitty/wezterm/...)
-- only Super+C/V are remapped (to Ctrl+Shift+C/V); Super+X/Z/F are no-ops so native Ctrl+X/Z/F keep
-- working. In excluded apps, the raw Super+<key> is passed through unchanged

---@param window HL.Window?
---@return string
local function active_class(window)
    window = window or hl.get_active_window()
    return window and window.class and window.class:lower() or ""
end

---@param shortcut table[]
---@param classes_to_pass string[]?
---@return function
local function rebind(shortcut, classes_to_pass)
    classes_to_pass = classes_to_pass or {}
    return function()
        local active_window = hl.get_active_window()
        local active_class_name = active_class(active_window)
        if utils.list_contains(classes_to_pass, active_class_name) then
            hl.dispatch(hl.dsp.pass({
                window = active_window,
            }))
            return
        end

        hl.dispatch(hl.dsp.send_shortcut(shortcut))
    end
end

local term_apps = {
    "neovide",
    "kitty",
    "org.wezfurlong.wezterm",
}

hl.bind("SUPER + C", rebind({ mods = "CTRL", key = "C" }, term_apps))
hl.bind("SUPER + V", rebind({ mods = "CTRL", key = "V" }, term_apps))
hl.bind("SUPER + X", rebind({ mods = "CTRL", key = "X" }, term_apps))
hl.bind("SUPER + A", rebind({ mods = "CTRL", key = "A" }, term_apps))
hl.bind("SUPER + W", rebind({ mods = "CTRL", key = "W" }, term_apps))
hl.bind("SUPER + Z", rebind({ mods = "CTRL", key = "Z" }, term_apps))
hl.bind("SUPER + F", rebind({ mods = "CTRL", key = "F" }, term_apps))
hl.bind("SUPER + SHIFT + Z", rebind({ mods = "CTRL + SHIFT", key = "Z" }, term_apps))
hl.bind("SUPER + L", rebind({ mods = "CTRL", key = "L" }, term_apps))
hl.bind("SUPER + T", rebind({ mods = "CTRL", key = "T" }, term_apps))
hl.bind("SUPER + R", rebind({ mods = "CTRL", key = "R" }, term_apps))
hl.bind("SUPER + H", rebind({ mods = "CTRL", key = "H" }, term_apps))
hl.bind("SUPER + left", rebind({ mods = "", key = "HOME" }))
hl.bind("SUPER + right", rebind({ mods = "", key = "END" }))
hl.bind("ALT + right", rebind({ mods = "CTRL", key = "right" }))
hl.bind("ALT + BACKSPACE", rebind({ mods = "CTRL", key = "BACKSPACE" }))
hl.bind("SUPER + BACKSPACE", rebind({ mods = "CTRL", key = "U" }))
hl.bind("ALT + left", rebind({ mods = "CTRL", key = "left" }))

-- ---------------------------------------------------------------------------
-- Screen captures
-- ---------------------------------------------------------------------------

hl.bind("SUPER + SHIFT + 4", hl.dsp.exec_cmd([[flameshot gui --clipboard]]))
hl.bind("SUPER + SHIFT + 3", hl.dsp.exec_cmd("screen-cap"))
hl.bind("SUPER + SHIFT + 2", hl.dsp.exec_cmd("screen-cap gif"))

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

hl.bind("SUPER + ALT + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + ALT + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + ALT + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + ALT + down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + ALT + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + ALT + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + ALT + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + ALT + j", hl.dsp.focus({ direction = "d" }))

-- ---------------------------------------------------------------------------
-- Workspaces
-- ---------------------------------------------------------------------------

-- CTRL + arrow/hjkl: switch to prev/next absolute workspace, drag it onto the current monitor.
hl.bind("CTRL + left", function()
    focus_ws_on_current_mon("-1")
end)
hl.bind("CTRL + right", function()
    focus_ws_on_current_mon("+1")
end)

-- Send the active window to prev/next absolute
-- workspace, drag that workspace onto the current monitor, AND follow it
-- (matches the trailing `1` arg to `move-workspace-mon.bash`).
for _, k in ipairs({ "left", "h" }) do
    hl.bind("SUPER + CTRL + " .. k, function()
        move_active_window_to_ws_on_current_mon("-1", true)
    end)
end
for _, k in ipairs({ "right", "l" }) do
    hl.bind("SUPER + CTRL + " .. k, function()
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
