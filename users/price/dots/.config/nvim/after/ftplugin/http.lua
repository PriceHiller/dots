vim.keymap.set("n", "<localleader>fr", ":Rest run<CR>", {
    buffer = true,
    silent = true,
})
vim.opt_local.commentstring = "# %s"
