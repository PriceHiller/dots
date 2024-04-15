vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.textwidth = 120
vim.opt_local.wrap = false

vim.keymap.set("n", "<leader>fr", "<cmd>MarkdownPreview<CR>", {
    buffer = true,
})
