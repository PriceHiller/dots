return {
    {
        "sbdchd/neoformat",
        keys = {
            { "<leader>nf", "<cmd>Neoformat<CR>", desc = "Neoformat: Format File" },
        },
        cmd = "Neoformat",
        config = function()
            vim.g.neoformat_python_black = {
                exe = "black",
                stdin = 1,
                args = { "-q", "-" },
            }
            vim.g.neoformat_enabled_python = { "black" }
        end,
    },
}
