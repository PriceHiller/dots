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
                        sign = {
                            name = { ".*" },
                            text = { ".*" },
                        },
                        click = "v:lua.ScSa",
                        condition = {
                            builtin.not_empty,
                        },
                    },
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

            vim.api.nvim_create_user_command("SCol", function()
                vim.wo.statuscolumn = "%{%v:lua.require('statuscol').get_statuscol_string()%}"
            end, {
                desc = "Set the current `statuscolumn` to statuscol.nvim's",
            })
        end,
    },
}
