vim.keymap.set("n", "<localleader>fr", function()
    vim.cmd.write()
    vim.cmd.terminal("deno run " .. vim.fn.expand("%"))
end, {
    buffer = true,
    silent = true,
})
