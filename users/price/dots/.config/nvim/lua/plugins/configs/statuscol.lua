return {
    {
        "luukvbaal/statuscol.nvim",
        config = function()
            local builtin = require("statuscol.builtin")

            require("statuscol").setup({
                setopt = true,
                relculright = false,
                segments = {
                    { text = { "%s" }, click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    {
                        text = {
                            function(args)
                                local fold = builtin.foldfunc(args)
                                if args.virtnum == 0 then
                                    return fold
                                else
                                    return ""
                                end
                            end,
                        },
                        click = "v:lua.ScFa",
                    },
                    {
                        text = {
                            function(args)
                                local hl = "%#NonText#"
                                if args.cul and args.virtnum == 0 and args.relnum == 0 then
                                    hl = "%#CursorLineSep#"
                                end
                                return hl .. "▕" .. "%*"
                            end,
                        },
                        condition = {
                            builtin.not_empty,
                        },
                    },
                },
            })
        end,
    },
}
