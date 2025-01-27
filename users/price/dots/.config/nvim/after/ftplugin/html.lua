vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

vim.keymap.set("n", "<localleader>fr", function()
    vim.system({ "xdg-open", vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) }, { detach = true })
end, {
    buffer = true,
    silent = true,
})
