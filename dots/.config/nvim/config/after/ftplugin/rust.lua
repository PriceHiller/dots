vim.keymap.set('n', '<leader>fr', ':RustRunnables<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fd', ':RustDebuggables<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fp', ':RustParentModule<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fJ', ':RustJoinLines<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fh', ':RustHoverActions<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fH', ':RustHoverRange<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fi', ':RustToggleInlayHints<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fm', ':RustExpandMacro<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fc', ':RustOpenCargo<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fk', ':RustMoveItemUp<CR>', {
    buffer = true,
})
vim.keymap.set('n', '<leader>fj', ':RustMoveItemDown<CR>', {
    buffer = true,
})

vim.opt.foldmethod = 'syntax'
