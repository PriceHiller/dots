-- Fallback rule for any monitor that doesn't have a more specific config.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

-- ---- Laptop lid handling ----
--
-- Hyprland exposes `switch:on:<name>` and `switch:off:<name>` binds (see
-- https://wiki.hypr.land/Configuring/Basics/Binds/#switches) which fire when
-- a switch device toggles. The switch name can be discovered via
-- `hyprctl devices`. By binding each event directly to its specific action,
-- the lid state is implicit in *which* bind fires -- no need to consult
-- `/proc/acpi` at every event.
--
-- `/proc/acpi` is still read once at startup so the monitor matches the
-- current physical lid state when Hyprland launches.

local LAPTOP_MON = "desc:Samsung Display Corp. 0x414D"
local LID_PATH = "/proc/acpi/button/lid/LID0/state"

---Configure the laptop monitor as enabled (lid open).
---
---Note: `disabled = false` is required to re-enable a monitor that was
---previously disabled -- without it, `hl.monitor()` leaves the disabled
---flag alone and the call appears to be a no-op.
local function enable_laptop_mon()
    hl.monitor({
        output = LAPTOP_MON,
        disabled = false,
        mode = "preferred",
        position = "0x0",
        scale = 1.5,
    })
end

--- Configure the laptop monitor as disabled (lid closed / clamshell mode).
local function disable_laptop_mon()
    hl.monitor({ output = LAPTOP_MON, disabled = true })
end

---Read the ACPI lid switch state once at startup. Returns "open",
---"closed", or nil if the file can't be read
---@return "open" | "closed" | nil
local function get_acpi_lid_state()
    local f = io.open(LID_PATH, "r")
    if not f then
        return nil
    end
    local line = f:read("*l")
    f:close()
    if not line then
        return nil
    end
    -- The file contains e.g. "state:      open" -- grab the trailing word.
    local state = line:match("(%S+)%s*$")
    return state and state:lower() or nil
end

-- Apply initial state once at startup.
if get_acpi_lid_state() == "closed" then
    disable_laptop_mon()
else
    enable_laptop_mon()
end

-- React to subsequent lid-switch events. `locked = true` keeps the bind
-- functional while a screen-locker / input inhibitor is active.
hl.bind("switch:off:Lid Switch", enable_laptop_mon, { locked = true })
hl.bind("switch:on:Lid Switch", disable_laptop_mon, { locked = true })

-- ---- Hyprpaper refresh on layout change ----
--
-- Hyprpaper does not always re-render its wallpapers cleanly when a
-- monitor is enabled or disabled at runtime -- closing the laptop lid
-- typically leaves the external monitor's wallpaper rendered at the old
-- (smaller) layout-effective dimensions, covering only part of the screen.
-- Re-issuing the `wallpaper` IPC command for each currently-assigned
-- monitor forces hyprpaper to redraw at the new size.
--
-- These IPC calls go to the hyprpaper daemon (not back into Hyprland), so
-- they cannot deadlock the compositor's event loop the way a synchronous
-- `hyprctl monitors` call would.
local function refresh_hyprpaper_wallpapers()
    -- `listactive` is read synchronously via popen because we need its
    -- output. The roundtrip is to hyprpaper, not Hyprland, so this is safe.
    local p = io.popen("hyprctl hyprpaper listactive 2>/dev/null")
    if not p then
        return
    end
    for line in p:lines() do
        -- listactive prints lines like "DP-4: /path/to/wallpaper.jpg"
        local mon, path = line:match("^%s*([^:]+):%s*(.+)%s*$")
        if mon and path then
            -- `hl.exec_cmd` is async and non-blocking, so multiple monitors
            -- can be refreshed without serializing on each child process.
            hl.exec_cmd(string.format('hyprctl hyprpaper wallpaper "%s,%s"', mon, path))
        end
    end
    p:close()
end

hl.on("monitor.layout_changed", refresh_hyprpaper_wallpapers)
