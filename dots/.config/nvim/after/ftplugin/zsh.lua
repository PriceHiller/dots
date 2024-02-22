vim.opt_local.expandtab = false

vim.keymap.set("n", "<leader>fr", function()
    vim.cmd.write()
    require("toggleterm").exec("zsh " .. vim.api.nvim_buf_get_name(0))
end, {
    buffer = true,
    desc = "ZSH: Save and Run Current Buffer",
})
