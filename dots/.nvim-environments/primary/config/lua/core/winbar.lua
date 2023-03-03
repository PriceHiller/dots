local M = {}

M.winbar = function()
    local win_number = "[" .. vim.api.nvim_win_get_number(0) .. "]"
    local ignore_fts = {
        "neo-tree",
        "dashboard",
        "alpha",
    }

    for _, ft in ipairs(ignore_fts) do
        if ft == vim.bo.filetype then
            return win_number .. " " .. ft
        end
    end

    local relative_path = vim.fn.fnamemodify(vim.fn.expand("%:h"), ":p:~:.")
    local filename = vim.fn.expand("%:t")
    return win_number .. "  " .. relative_path .. filename
end

M.setup = function()
    -- Winbar
    vim.opt.winbar = "%{%v:lua.require('core.winbar').winbar()%}"
end

return M
