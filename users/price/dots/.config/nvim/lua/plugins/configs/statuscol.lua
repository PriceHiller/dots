return {
    {
        "luukvbaal/statuscol.nvim",
        config = function()
            local builtin = require("statuscol.builtin")

            ---@class MyStatusColNvimArgsFold
            ---@field width integer current width of the fold column
            ---@field close string foldclose ""
            ---@field open string foldopen ""
            ---@field sep string foldsep " "

            ---@class MyStatusColNvimArgs
            ---@field lnum integer v:lnum
            ---@field relnum integer v:relnum
            ---@field virtnum integer v:virtnum
            ---@field buf integer buffer handle of drawn window
            ---@field win integer window handle of drawn window
            ---@field actual_curbuf integer buffer handle of |g:actual_curwin|
            ---@field actual_curwin integer window handle of |g:actual_curbuf|
            ---@field nu boolean 'number' option value
            ---@field rnu boolean 'relativenumber' option value
            ---@field cul "line" | "screenline" | "number" | "both" 'cursorline' option value
            ---@field empty boolean statuscolumn is currently empty
            ---@field fold MyStatusColNvimArgsFold fold values
            ---@field tick integer FFI display_tick value
            ---@field wp any FFI win_T pointer handle

            ---@class MyStatusColNvimSegArgsSign
            ---@field name? string[] table of Lua patterns to match the legacy sign name against, example: { " .* " }
            ---@field text? string[] table of Lua patterns to match the extmark sign text against, example: { " .* " }
            ---@field namespace? string[] table of Lua patterns to match the extmark sign namespace against, example: { " .* " }
            ---@field maxwidth? integer maximum number of signs that will be displayed in this segment
            ---@field colwidth? integer number of display cells per sign in this segment
            ---@field auto? boolean | string boolean or string indicating what will be drawn when no signs matching the pattern are currently placed in the buffer.
            ---@field wrap? boolean when true, signs in this segment will also be drawn on the virtual or wrapped part of a line (when v:virtnum != 0).
            ---@field fillchar? string character used to fill a segment with less signs than maxwidth
            ---@field fillcharhl? string highlight group used for fillchar (SignColumn/CursorLineSign if omitted)
            ---@field foldclosed? boolean when true, show signs from lines in a closed fold on the first line

            ---@alias MyStatusColNvimSegArgsText (string | fun(args: MyStatusColNvimArgs): string)
            ---@alias MyStatusColNvimSegArgsCond (boolean | fun(args: MyStatusColNvimArgs): boolean?)

            ---@class MyStatusColNvimSegArgs
            ---@field text MyStatusColNvimSegArgsText[] table of strings or functions returning a string
            ---@field click? string %@ click function label, applies to each text element, example: "v:lua.ScFa"
            ---@field hl? string %# highlight group label, applies to each text element
            ---@field condition? MyStatusColNvimSegArgsCond[] table of booleans or functions returning a boolean
            ---@field sign? MyStatusColNvimSegArgsSign sign values

            require("statuscol").setup({
                setopt = true,
                relculright = false,
                ---@type MyStatusColNvimSegArgs[]
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
                    {
                        text = { builtin.lnumfunc },
                        click = "v:lua.ScLa",
                    },
                    {
                        text = {
                            function(args)
                                ---@type string
                                local fold = builtin.foldfunc(args)
                                if #fold > 0 and args.virtnum == 0 then
                                    return fold .. " "
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
