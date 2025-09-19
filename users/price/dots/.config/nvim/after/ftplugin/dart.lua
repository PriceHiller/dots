vim.opt_local.shiftwidth = 2

vim.keymap.set("n", "<localleader>fr", function()
    require("toggleterm").exec("dart run")
end, {
    buffer = true,
    silent = true,
})
