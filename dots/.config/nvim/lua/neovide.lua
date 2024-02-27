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

-- Do not use fullscreen on startup — annoying af
vim.g.neovide_remember_window_size = false
vim.g.neovide_fullscreen = false

-- Allow clipboard copy paste in neovim
vim.keymap.set("n", "<D-s>", ":w<CR>", { noremap = true, silent = true }) -- Save
vim.keymap.set("v", "<D-c>", '"+y', { noremap = true, silent = true }) -- Copy
vim.keymap.set("n", "<D-v>", '"+P', { noremap = true, silent = true }) -- Paste normal mode
vim.keymap.set("v", "<D-v>", '"+P', { noremap = true, silent = true }) -- Paste visual mode
vim.keymap.set("c", "<D-v>", "<C-R>+", { noremap = true, silent = true }) -- Paste command mode
vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli', { noremap = true, silent = true }) -- Paste insert mode
vim.keymap.set('t', '<D-v>', '<C-\\><C-n>"+Pi', { noremap = true, silent = true }) -- Paste terminal mode

vim.keymap.set("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.keymap.set("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.keymap.set("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

-- Next/prev tabs
vim.keymap.set({ "", "!", "v", "t" }, "<D-x>", "<cmd>tabnext<CR>", { noremap = true, silent = true })
vim.keymap.set({ "", "!", "v", "t" }, "<D-z>", "<cmd>tabprevious<CR>", { noremap = true, silent = true })

-- Spawn new terminal in new tab
vim.keymap.set({ "", "!", "v", "t" }, "<D-t>", "<cmd>tabnew | terminal<CR>", { noremap = true, silent = true })

