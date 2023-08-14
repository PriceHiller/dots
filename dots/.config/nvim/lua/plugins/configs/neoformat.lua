return {
    {
        "sbdchd/neoformat",
        cmd = "Neoformat",
        config = function()
            vim.g.neoformat_python_black = {
                exe = "black",
                stdin = 1,
                args = { "-q", "-" }
            }
            vim.g.neoformat_enabled_python = { "black" }
        end,
    },
}
