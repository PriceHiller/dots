-- Floating and Popupmenu Transparency
vim.opt.winblend = 10
vim.opt.pumblend = 10

-- Float blur amount
vim.g.neovide_floating_blur_amount_x = 5.0
vim.g.neovide_floating_blur_amount_y = 5.0
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5

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

-- Next/prev tabs
vim.api.nvim_set_keymap("n", "<D-x>", ":tabnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<D-z>", ":tabprevious<CR>", { noremap = true, silent = true })

-- Spawn new terminal in new tab
vim.api.nvim_set_keymap("n", "<D-t>", ":tabnew | terminal<CR>", { noremap = true, silent = true })

