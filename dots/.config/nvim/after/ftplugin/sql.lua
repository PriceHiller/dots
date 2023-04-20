vim.keymap.set("n", "<leader>fe", "<Plug>(sqls-execute-query)", {
    buffer = true,
})
vim.keymap.set("v", "<leader>fe", "<Plug>(sqls-execute-query)", {
    buffer = true,
})

vim.keymap.set("n", "<leader>fsd", ":SqlsSwitchDatabase<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fsc", ":SqlsSwitchConnection<CR>", {
    buffer = true,
})
