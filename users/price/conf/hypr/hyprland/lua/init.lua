-- Hyprland Lua entry point. Sourced from `default.nix` via:
--   wayland.windowManager.hyprland.extraConfig = "require(\"./lua\")"
--
-- Each module is in its own file; an error in one `require` does not abort
-- the others (Hyprland evaluates each in its own scope).

-- Make the directory containing this file the root of `require()` lookups
-- so `require("colors")` resolves to ./colors.lua, etc.
local dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = dir .. "?.lua;" .. dir .. "?/init.lua;" .. package.path

require("colors")
require("appearance")
require("monitors")
require("bindings")

-- Per-application configs (workspace rules, window rules, submaps, etc.)
require("applications.gromit_mpx")
require("applications.xwaylandvideobridge")
