local nvim_treesitter = require("nvim-treesitter.configs")

nvim_treesitter.setup({
    ensure_installed = {
        "norg",
    },
    highlight = {
        enable = true,
    },
    matchup = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    },
})

require('treesitter-context').setup({})
vim.cmd.TSContextEnable()
