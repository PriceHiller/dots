local M = {}

M.winbar = function()
    local win_number = '[' .. vim.api.nvim_win_get_number(0) .. ']'
    local ignore_fts = {
        'neo-tree',
        'dashboard',
    }

    for _, ft in ipairs(ignore_fts) do
        if ft == vim.bo.filetype then
            return win_number
        end
    end
    return win_number .. ' %f'
end

M.setup = function()
    -- Winbar
    vim.opt.winbar = "%{%v:lua.require('core.winbar').winbar()%}"
end

return M
