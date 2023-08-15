return {
    {
        "akinsho/toggleterm.nvim",
        keys = {
            { "<leader><leader>", "<cmd>ToggleTerm<CR>", desc = "ToggleTerm: Toggle" },
        },
        opts = {
            start_in_insert = false,
            direction = "float",
            autochdir = true,
            winbar = {
                enable = true,
                name_formatter = function(term) --  term: Terminal
                    return term.name
                end,
            },
        },
        cmd = {
            "ToggleTerm",
            "ToggleTermSetName",
            "ToggleTermToggleAll",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualLines",
            "ToggleTermSendVisualSelection",
        },
    },
}
