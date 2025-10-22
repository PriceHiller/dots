vim.keymap.set("n", "<localleader>fr", function()
    vim.cmd.write()
    vim.cmd.terminal("deno run " .. vim.fn.expand("%"))
end, {
    buffer = true,
    silent = true,
})

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
