local wezterm = require("wezterm")
local wlib = require("lib.wlib")
local os_detected = require("lib.wlib").get_os_arch().name:lower()

local M = {}

---@class LogOpts
---@field level string?
---| "info"
---| "debug"
---| "warning"
---| "err"
---@field prefix string?
---@field ignore_result boolean?

---Log to systemd log
---@param message string
---@param opts LogOpts
local function system_log(message, opts)
    local log_unit = "wezterm"
    if os_detected == "linux" then
        local handle = io.popen(string.format("systemd-cat -t %s -p %s echo '%s'", log_unit, opts.level:lower(), message))
        if not opts.ignore_result or opts.ignore_result == nil then
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
end


---Format message with log options
---@param message string
---@param opts LogOpts
local function format_message(message, opts)
    local formatted_str = message
    if opts.prefix then
        formatted_str = string.format("%s: %s", opts.prefix, message)
    end
    return formatted_str
end

---Log a debug message
---@param message string
---@param opts LogOpts?
function M.debug(message, opts)
    opts = opts or {}
    message = format_message(message, opts)
    local merged_opts = wlib.Table.merge(opts, { level = "debug" })
    system_log(message, merged_opts)
end

---Log a info message
---@param message string
---@param opts LogOpts?
function M.info(message, opts)
    opts = opts or {}
    message = format_message(message, opts)
    wezterm.log_info(message)
    local merged_opts = wlib.Table.merge(opts, { level = "info" })
    system_log(message, merged_opts)
end

---Log a warning message
---@param message string
---@param opts LogOpts?
function M.warn(message, opts)
    opts = opts or {}
    message = format_message(message, opts)
    wezterm.log_warn(message)
    local merged_opts = wlib.Table.merge(opts, { level = "warning" })
    system_log(message, merged_opts)
end

---Log a error message
---@param message string
---@param opts LogOpts?
function M.error(message, opts)
    opts = opts or {}
    message = format_message(message, opts)
    wezterm.log_error(message)
    local merged_opts = wlib.Table.merge(opts, { level = "err" })
    system_log(message, merged_opts)
end

return M
