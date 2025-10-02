vim.opt_local.shiftwidth = 2

vim.keymap.set("n", "<localleader>fr", function()
    require("toggleterm").exec("dart run")
end, {
    buffer = true,
    silent = true,
})

vim.keymap.set("n", "<localleader>ff", "<cmd>FlutterOutlineOpen<CR>", {
    buffer = true,
    silent = true,
    desc = "Flutter: Open Outline",
})
