vim.keymap.set("n", "<localleader>fr", ":Rest run<CR>", {
    buffer = true,
    silent = true,
})
vim.keymap.set("n", "<leader>fl", "<Plug>Rest run last", {
    buffer = true,
    silent = true,
})
vim.opt_local.commentstring = "# %s"
