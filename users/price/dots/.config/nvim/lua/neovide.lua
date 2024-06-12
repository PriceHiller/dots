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

-- Cursor goodiness
vim.g.neovide_cursor_vfx_mode = "ripple"
vim.g.neovide_cursor_vfx_particle_lifetime = 0.3

-- Allow clipboard copy paste in neovim
vim.keymap.set({ "n", "v" }, "<D-v>", '"+P') -- Paste normal and visual mode
vim.keymap.set({ "i", "c" }, "<D-v>", "<C-R>+") -- Paste insert and command mode
vim.keymap.set("t", "<D-v>", [[<C-\><C-N>"+Pi]]) -- Paste terminal mode

-- Next/prev tabs
vim.keymap.set({ "", "!", "v", "t" }, "<D-x>", "<cmd>tabnext<CR>", { noremap = true, silent = true })
vim.keymap.set({ "", "!", "v", "t" }, "<D-z>", "<cmd>tabprevious<CR>", { noremap = true, silent = true })

-- Spawn new terminal in new tab
vim.keymap.set({ "", "!", "v", "t" }, "<D-t>", "<cmd>tabnew | terminal<CR>", { noremap = true, silent = true })

-- Spawn terminal in split direction
vim.keymap.set(
    { "", "!", "v", "t" },
    "<C-S-Right>",
    "<cmd>vertical belowright terminal<CR>",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "", "!", "v", "t" },
    "<C-S-Left>",
    "<cmd>vertical aboveleft terminal<CR>",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "", "!", "v", "t" },
    "<C-S-Up>",
    "<cmd>horizontal aboveleft terminal<CR>",
    { noremap = true, silent = true }
)
vim.keymap.set(
    { "", "!", "v", "t" },
    "<C-S-Down>",
    "<cmd>horizontal belowright terminal<CR>",
    { noremap = true, silent = true }
)

-- Zoom in & out
vim.g.neovide_scale_factor = 1
local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end
vim.keymap.set("n", "<D-=>", function()
    change_scale_factor(1.1)
end, { silent = true, desc = "Neovide: Zoom In" })

vim.keymap.set("n", "<D-->", function()
    change_scale_factor(1 / 1.1)
end, { noremap = true, silent = true, desc = "Neovide: Zoom out" })

vim.keymap.set("n", "<D-0>", function()
    vim.g.neovide_scale_factor = 1
end, { noremap = true, silent = true, desc = "Neovide: Reset Zoom" })

-- Set Neovide specific vars for use elsewhere (e.g. terminal sessions)
vim.env.NEOVIDE_SESSION = 1
