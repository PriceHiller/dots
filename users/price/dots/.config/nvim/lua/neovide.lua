-- Floating and Popupmenu Transparency
vim.opt.winblend = 30
vim.opt.pumblend = 90

-- Bg opacity
vim.g.neovide_normal_opacity = 0.8

-- Float blur amount
vim.g.neovide_floating_blur_amount_x = 25.0
vim.g.neovide_floating_blur_amount_y = 25.0

-- Floating window corner radius
vim.g.neovide_floating_corner_radius = 0.2

-- Do not use fullscreen on startup — annoying af
vim.g.neovide_remember_window_size = false
vim.g.neovide_fullscreen = false

-- Cursor goodiness
vim.g.neovide_cursor_vfx_mode = "ripple"
vim.g.neovide_cursor_vfx_particle_lifetime = 0.3

-- ===== Allow clipboard copy paste in neovim
-- Paste normal and visual mode
vim.keymap.set({ "n", "v" }, "<D-v>", '"+P')
-- Paste in command mode
vim.keymap.set("c", "<D-v>", "<C-R>+")
-- Paste in insert mode
vim.keymap.set("i", "<D-v>", function()
    local register = "+"
    local register_type = vim.fn.getregtype(register)
    local register_content = vim.fn.getreg(register)
    -- Set the register to be pasted `charwise`, see `:h charwise`
    vim.fn.setreg(register, register_content, "c")
    -- Handle pasting at the end of lines. Because we're invoking `normal!` commands whilst in
    -- `insert` mode, we have to handle EOL stuff. For some reason (and I'm too lazy to investiage),
    -- `nvim_feedkeys` doesn't block correctly here and the last `setreg` call is triggered too
    -- early.
    local cmd = '"' .. register .. "g"
    if vim.fn.charcol(".") == (vim.fn.charcol("$")) then
        -- At eol, paste AFTER the cursor
        vim.cmd.normal({ cmd .. "p", bang = true })
        -- Since we're in insert mode and we just invoked a `normal` mode command, the cursor is
        -- actually offset one column to the left from where it should be -- move it over by one.
        local win = vim.api.nvim_get_current_win()
        local row, col = unpack(vim.api.nvim_win_get_cursor(win))
        vim.api.nvim_win_set_cursor(win, { row, col + 1 })
    else
        vim.cmd.normal({ cmd .. "P", bang = true })
    end
    -- Restore the register's type back to what it was previously
    vim.fn.setreg(register, register_content, register_type)
end)
-- Paste terminal mode
vim.keymap.set("t", "<D-v>", [[<C-\><C-N>"+Pi]])

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

-- Group layers for shadows & blurring across entire group
vim.g.experimental_layer_grouping = true
