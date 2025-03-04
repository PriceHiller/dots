return {
    {
        "luukvbaal/statuscol.nvim",
        config = function()
            local builtin = require("statuscol.builtin")

            require("statuscol").setup({
                setopt = true,
                relculright = false,
                segments = {
                    {
                        text = { "%s" },
                        click = "v:lua.ScSa",
                    },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    {
                        text = { builtin.foldfunc, " " },
                        click = "v:lua.ScFa",
                        condition = {
                            function(args)
                                return vim.api.nvim_get_option_value("foldcolumn", { win = args.win }) ~= "0"
                            end,
                        },
                    },
                    {
                        text = { "▕" },
                        hl = "NonText",
                        condition = {
                            function(args)
                                return #vim.api.nvim_get_option_value("bufhidden", { buf = args.buf }) == 0
                            end,
                        },
                    },
                },
            })
        end,
    },
}
