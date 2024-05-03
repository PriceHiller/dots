vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

vim.keymap.set("n", "<leader>fr", ":!xdg-open %<CR>", {
    buffer = true,
    silent = true,
})
