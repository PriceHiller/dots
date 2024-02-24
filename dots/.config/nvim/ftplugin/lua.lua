vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true

vim.keymap.set("n", "<leader>fr", ":%lua<CR>", {
    buffer = true,
    silent = true,
})

vim.keymap.set("v", "<leader>fr", ":lua<CR>", {
    buffer = true,
    silent = true,
})
