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
                        text = {
                            function(args)
                                local get_mark = function()
                                    local bufname = vim.api.nvim_buf_get_name(args.buf)
                                    local global_mark_buf = vim.iter(vim.fn.getmarklist())
                                        :filter(function(mark)
                                            local lnum = mark.pos[2]
                                            return lnum == args.lnum
                                                and (mark.file == bufname or vim.fn.expand(mark.file) == bufname)
                                        end)
                                        :next()

                                    if global_mark_buf then
                                        return global_mark_buf.mark:sub(-1)
                                    end

                                    local local_mark_buf = vim.iter(vim.fn.getmarklist(args.buf))
                                        :filter(function(mark)
                                            local lnum = mark.pos[2]
                                            return lnum == args.lnum
                                        end)
                                        :next()
                                    if local_mark_buf then
                                        return local_mark_buf.mark:sub(-1)
                                    end

                                    return " "
                                end
                                local mark = get_mark()
                                if args.relnum == 0 then
                                    return "%#Character#" .. mark .. "%*"
                                else
                                    return "%#Question#" .. mark .. "%*"
                                end
                            end,
                        },
                        condition = {
                            function(args)
                                return args.virtnum == 0
                            end,
                            std_condition,
                        },
                    },
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
