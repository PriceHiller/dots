vim.opt_local.commentstring = "# %s"

vim.keymap.set("n", "<localleader>fr", function()
    local curr_file = vim.api.nvim_buf_get_name(0)
    local curr_dir = vim.fn.fnamemodify(curr_file, ":h")
    local fname = vim.fn.fnamemodify(curr_file, ":t:r")

    local target_dir = curr_dir .. "/.target"
    local object_path = target_dir .. "/obj.o"
    local executable_path = target_dir .. "/" .. fname

    vim.fn.mkdir(target_dir, "p")

    local cmd = {
        "nasm",
        "-felf64",
        curr_file,
        "-o",
        object_path,
        "&& \n",
        "ld",
        object_path,
        "-o",
        executable_path,
        "&& \n",
        executable_path,
    }
    require("toggleterm").exec(table.concat(cmd, " "))
end, {
    buffer = true,
})
