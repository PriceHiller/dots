local M = {}
M.setup = function()
    vim.api.nvim_create_user_command("StripTrailSpace", "%s/\\s\\+$//e", {})
end

return M
