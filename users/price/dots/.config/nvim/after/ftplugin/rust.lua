vim.opt_local.textwidth = 80
vim.keymap.set("n", "<localleader>fr", ":RustLsp runnables<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fd", ":RustLsp debuggables<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fp", ":RustLsp openCargo<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fJ", ":RustLsp joinLines<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fh", ":RustLsp hover actions<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fH", ":RustLsp hover range<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fm", ":RustLsp expandMacro<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fc", ":RustLsp openCargo<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fk", ":RustLsp moveItem up<CR>", {
    buffer = true,
})
vim.keymap.set("n", "<localleader>fj", ":RustLsp moveItem down<CR>", {
    buffer = true,
})
