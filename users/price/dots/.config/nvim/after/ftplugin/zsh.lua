local write_file = require("utils.funcs").write_file

vim.opt_local.expandtab = false

vim.keymap.set("n", "<localleader>fr", function()
    require("toggleterm").exec(
        write_file(
            vim.fn.tempname(),
            "0700",
            { "#!/usr/bin/env", "-S", "nix", "shell", "nixpkgs#zsh", "--command", "zsh" },
            unpack(vim.api.nvim_buf_get_lines(0, 0, -1, false))
        )
    )
end, {
    buffer = true,
    desc = "Bash: Run Current Buffer",
})
