return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        config = function()
            require("noice").setup({
                lsp = {
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                    },
                },
                presets = {
                    long_message_to_split = true,
                    command_palette = true,
                },
                views = {
                    cmdline_popup = {
                        border = {
                            style = "none",
                        },
                        position = {
                            row = "99%",
                            col = "0%",
                        },
                    },
                    cmdline_input = {
                        border = {
                            style = "rounded",
                        },
                    },
                },
                popupmenu = {
                    backend = "cmp",
                },
                routes = {
                    {
                        filter = { event = "msg_show", find = "Hop .*:%s*" },
                        opts = { skip = true },
                    },
                    -- Ignore `written` message
                    {
                        filter = { event = "msg_show", find = '^".*" .*%d*L, %d*B written$' },
                        opts = { skip = true },
                    },
                    -- Ignore `undo` message
                    {
                        filter = { event = "msg_show", find = "^%d+ .*; before #%d+ .*$" },
                        opts = { skip = true },
                    },
                    -- Ignore `redo` message
                    {
                        filter = { event = "msg_show", find = "^%d+ .*; after #%d+ .*$" },
                        opts = { skip = true },
                    },
                    {
                        view = "split",
                        filter = { event = "msg_show", min_height = 20 },
                    },
                },
            })

            vim.opt.cmdheight = 0
        end,
    },
}
