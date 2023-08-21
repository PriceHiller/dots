-- We have to provide a good gpu for wezterm to use gpu acceleration. We ideally want to use a vullkan front end, but if
-- we are unable to locate a card that supports Vulkan we fall back to OpenGL
local config = {}
local wezterm = require("wezterm")
local log = require("lib.log")

local found_valid_gpu = false
for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
    if gpu.backend == "Vulkan" and not found_valid_gpu then
        log.info(
            "Found Usable Vulkan GPU -- Device Name -> " .. gpu.name .. "; Device Type -> " .. gpu.device_type
        )
        config.webgpu_preferred_adapter = gpu
        config.front_end = "WebGpu"
        config.webgpu_power_preference = "HighPerformance"
        found_valid_gpu = true
    end
end

if not found_valid_gpu then
    log.warn("Unable to locate a Vulkan-supported GPU, falling back to OpenGL")
    config.front_end = "OpenGL"
end

return config
