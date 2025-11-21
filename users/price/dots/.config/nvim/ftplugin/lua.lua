local opt = vim.opt_local

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

local success, snacks = pcall(require, "snacks")
if success then
    vim.keymap.set({ "n", "v" }, "<localleader>fd", snacks.debug.run, {
        buffer = true,
        silent = true,
        desc = "Evaluate lua with `Snacks.debug.run`",
    })
end

vim.keymap.set("n", "<localleader>fr", ":%lua<CR>", {
    buffer = true,
    silent = true,
    desc = "Evaluate lua file",
})

vim.keymap.set("v", "<localleader>fr", ":lua<CR>", {
    buffer = true,
    silent = true,
    desc = "Evaluate selected lua",
})

opt.formatlistpat = require("utils.formatpat")
    .new({
        pat = {
            [[---@\S*]],
            [[--]],
            [[-]],
            [[\d\.]],
            [[+]],
        },
    })
    :listpat()
