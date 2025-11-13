---@param program string
---@return string
local get_exe_path = function(program)
    local path = vim.fn.exepath(program)
    if #path == 0 then
        error(("`%s` not found in `$PATH`"):format(program))
    end
    return path
end

return {
    init_options = {
        ["language_server_php_cs_fixer.enabled"] = true,
        ["language_server_php_cs_fixer.bin"] = get_exe_path("php-cs-fixer"),
        ["language_server_psalm.enabled"] = true,
        ["language_server_psalm.bin"] = get_exe_path("psalm"),
    },
}
