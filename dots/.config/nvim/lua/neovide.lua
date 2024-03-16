-- Floating and Popupmenu Transparency
vim.opt.winblend = 20
vim.opt.pumblend = 10

-- Float blur amount
vim.g.neovide_floating_blur_amount_x = 10.0
vim.g.neovide_floating_blur_amount_y = 10.0
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5

-- Do not use fullscreen on startup — annoying af
vim.g.neovide_remember_window_size = false
vim.g.neovide_fullscreen = false

-- Allow clipboard copy paste in neovim
vim.keymap.set({ "n", "v" }, "<D-v>", '"+P') -- Paste normal and visual mode
vim.keymap.set({ "i", "c" }, "<D-v>", "<C-R>+") -- Paste insert and command mode
vim.keymap.set("t", "<D-v>", [[<C-\><C-N>"+P]]) -- Paste terminal mode

-- Next/prev tabs
vim.keymap.set({ "", "!", "v", "t" }, "<D-x>", "<cmd>tabnext<CR>", { noremap = true, silent = true })
vim.keymap.set({ "", "!", "v", "t" }, "<D-z>", "<cmd>tabprevious<CR>", { noremap = true, silent = true })

-- Spawn new terminal in new tab
vim.keymap.set({ "", "!", "v", "t" }, "<D-t>", "<cmd>tabnew | terminal<CR>", { noremap = true, silent = true })
