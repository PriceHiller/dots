vim.opt_local.shiftwidth = 2
vim.opt_local.modeline = true
vim.keymap.set("n", "<localleader>ff", function()
    vim.b.org_indent_mode = not vim.b.org_indent_mode
end, {
    buffer = true,
    desc = "Org: Toggle Indent Mode",
})
