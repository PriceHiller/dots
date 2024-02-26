vim.opt.linespace = -1

-- Floating and Popupmenu Transparency
vim.opt.winblend = 10
vim.opt.pumblend = 10

-- Allow clipboard copy paste in neovim
vim.keymap.set("n", "<D-s>", ":w<CR>", { noremap = true, silent = true }) -- Save
vim.keymap.set("v", "<D-c>", '"+y', { noremap = true, silent = true }) -- Copy
vim.keymap.set("n", "<D-v>", '"+P', { noremap = true, silent = true }) -- Paste normal mode
vim.keymap.set("v", "<D-v>", '"+P', { noremap = true, silent = true }) -- Paste visual mode
vim.keymap.set("c", "<D-v>", "<C-R>+", { noremap = true, silent = true }) -- Paste command mode
vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli', { noremap = true, silent = true }) -- Paste insert mode
vim.keymap.set('t', '<D-v>', '<C-\\><C-n>"+Pi', { noremap = true, silent = true }) -- Paste terminal mode

vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
