vim.opt_local.commentstring = "# %s"

vim.keymap.set("n", "<leader>fr", function()
    local curr_file = vim.fn.expand("%:p")
    vim.fn.expand("%:p")
    local curr_dir = vim.fn.expand("%:p:h")
    vim.fn.expand("%:p")
    require("toggleterm").exec(
        string.format(
            "as %s -o %s/obj.o && ld %s/obj.o -o %s/out && %s/out",
            curr_file,
            curr_dir,
            curr_dir,
            curr_dir,
            curr_dir
        )
    )
end, {
    buffer = true,
})
