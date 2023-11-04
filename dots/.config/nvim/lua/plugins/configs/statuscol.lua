return {
    {
        "luukvbaal/statuscol.nvim",
        opts = function()
            local builtin = require("statuscol.builtin")
            return {
                foldfunc = "builtin",
                setopt = true,
                relculright = false,
                segments = {
                    { text = { "%s" }, click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
                },
            }
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 0,
            },
        },
    },
}
