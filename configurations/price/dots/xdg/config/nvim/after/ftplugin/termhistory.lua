vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.keymap.set("n", "q", "<cmd>quit!<CR>", {
    buffer = true,
    remap = true,
})

vim.keymap.set("n", "i", function()
    vim.notify("Insert mode disabled in termhistory")
end, {
    buffer = true,
    remap = true,
})
