return {
    {
        "luukvbaal/statuscol.nvim",
        opts = function()
            local builtin = require("statuscol.builtin")

            local std_condition = function(args)
                return #vim.api.nvim_get_option_value("bufhidden", { buf = args.buf }) == 0
            end

            return {
                setopt = true,
                relculright = false,
                segments = {
                    { text = { "%s" }, click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
                    {
                        -- Padding for a missing fold icon
                        text = { " " },
                        condition = {
                            function(args)
                                return args.virtnum ~= 0
                            end,
                            std_condition,
                        },
                    },
                    {
                        text = { "▕" },
                        hl = "NonText",
                        condition = {
                            std_condition,
                        },
                    },
                },
            }
        end,
    },
}
