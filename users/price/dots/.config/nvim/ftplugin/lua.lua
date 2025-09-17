local opt = vim.opt_local

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

vim.keymap.set("n", "<localleader>fr", ":%lua<CR>", {
    buffer = true,
    silent = true,
})

vim.keymap.set("v", "<localleader>fr", ":lua<CR>", {
    buffer = true,
    silent = true,
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
