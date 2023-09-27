vim.keymap.set("n", "<leader>fr", "<Plug>RestNvim", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fp", "<Plug>RestNvimPreview", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fl", "<Plug>RestNvimLast", {
    buffer = true,
})
vim.opt_local.commentstring = "# %s"
