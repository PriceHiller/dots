local opt_local = vim.opt_local

opt_local.tabstop = 2
opt_local.shiftwidth = 2

vim.api.nvim_buf_set_option(0, "commentstring", "# %s")

vim.keymap.set("n", "<leader>fr", function ()
    local cmd = {
        "nix-instantiate",
        "--eval",
        vim.api.nvim_buf_get_name(0)
    }
    require("toggleterm").exec(table.concat(cmd, " "))
end, {
    buffer = true,
})
