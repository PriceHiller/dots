vim.keymap.set("n", "<leader>fr", "<Cmd>Hurl<CR>", {
    buffer = true,
})

vim.opt_local.commentstring = "# %s"

vim.keymap.set("n", "<leader>fr", "<cmd>HurlRunner<CR>", {
    desc = "Hurl: Runner",
})
vim.keymap.set("n", "<leader>fa", "<cmd>HurlRunnerAt<CR>", {
    desc = "Hurl: Run Api request",
})
vim.keymap.set("n", "<leader>fe", "<cmd>HurlRunnerToEntry<CR>", {
    desc = "Hurl: Run Api request to entry",
})
vim.keymap.set("n", "<leader>fm", "<cmd>HurlToggleMode<CR>", {
    desc = "Hurl: Toggle Mode",
})
vim.keymap.set("n", "<leader>rv", "<cmd>HurlVerbose<CR>", {
    desc = "Hurl: Run Api in verbose mode",
})
vim.keymap.set("v", "<leader>fr", ":HurlRunner<CR>", {
    desc = "Hurl: Runner",
})
