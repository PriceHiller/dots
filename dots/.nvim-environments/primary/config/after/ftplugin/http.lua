vim.keymap.set('n', '<leader>fr', '<Plug>RestNvim', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fp', '<Plug>RestNvimPreview', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fl', '<Plug>RestNvimLast', {
    buffer = true,
})

vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
