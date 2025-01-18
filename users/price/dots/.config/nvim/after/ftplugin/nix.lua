local opt_local = vim.opt_local
local utils = require("utils.funcs")

opt_local.tabstop = 2
opt_local.shiftwidth = 2
opt_local.commentstring = "# %s"

local nix_eval = function()
    return table.concat({
        "nix",
        "eval",
        "--expr",
        '"$(cat << __EOS__\n'
            .. vim.iter(vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}):join("\n")
            .. '\n__EOS__\n)"',
    }, " ")
end

vim.keymap.set("n", "<localleader>fr", function()
    vim.cmd.write()
    require("toggleterm").exec("nix eval --file " .. vim.api.nvim_buf_get_name(0))
end, {
    buffer = true,
    desc = "Nix: Run with default output",
})

vim.keymap.set("n", "<leader>fj", function()
    vim.cmd.write()
    local cmd = {
        "nix eval --file " .. vim.api.nvim_buf_get_name(0),
        "|",
        "jq",
    }
    require("toggleterm").exec(table.concat(cmd, " "))
end, {
    buffer = true,
    desc = "Nix: Run with json output",
})
