vim.opt_local.textwidth = 80
vim.keymap.set("n", "<localleader>fr", ":RustLsp runnables<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fd", ":RustLsp debuggables<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fp", ":RustLsp openCargo<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fJ", ":RustLsp joinLines<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fh", ":RustLsp hover actions<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fH", ":RustLsp hover range<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fm", ":RustLsp expandMacro<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fc", ":RustLsp openCargo<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fk", ":RustLsp moveItem up<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<leader>fj", ":RustLsp moveItem down<CR>", {
    buffer = true,
})
