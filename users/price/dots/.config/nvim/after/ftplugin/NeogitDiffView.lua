local win_id = vim.api.nvim_get_current_win()
vim.schedule(function()
    vim.api.nvim_set_option_value("statuscolumn", [[%!v:lua.StatusCol()]], {
        win = win_id,
    })
end)
