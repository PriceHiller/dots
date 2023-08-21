local wezterm = require("wezterm")
local os_detected = require("lib.wlib").get_os_arch().name:lower()

local M = {}

---comment
---@param message string
---@param log_level string
---| "info"
---| "debug"
---| "warning"
---| "err"
local function system_log(message, log_level)
    local log_unit = "wezterm"
    if os_detected == "linux" then
        print(string.format("systemd-cat -t %s -p %s echo '%s'", log_unit, log_level:lower(), message))
        local handle = io.popen(string.format("systemd-cat -t %s -p %s echo '%s'", log_unit, log_level:lower(), message))
        ---@diagnostic disable-next-line: need-check-nil
        local output = handle:read("*a")

        if output == nil then
            output = "Handle did not return any content!"
        end

        ---@diagnostic disable-next-line: need-check-nil
        local success = handle:close()
        if success == nil or not success then
            wezterm.log_warn(
                string.format("'systemd-cat' did not indicate a successful run!\nHandle Output:\n%s", output)
            )
        end
    end
end

function M.debug(message)
    system_log(message, "debug")
end

function M.info(message)
    wezterm.log_info(message)
    system_log(message, "info")
end

function M.warn(message)
    wezterm.log_warn(message)
    system_log(message, "warning")
end

function M.error(message)
    wezterm.log_error(message)
    system_log(message, "err")
end

return M
