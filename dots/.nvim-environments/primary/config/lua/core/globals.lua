local g = vim.g

local M = {}

M.setup = function()
    -- g.python3_host_prog = ("(%s)/.pyenv/shims/python3"):format(os.getenv("HOME"))
    -- Disable netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
end

return M
