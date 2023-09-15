return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                long_message_to_split = true,
                inc_rename = true,
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
            },
            popupmenu = {
                backend = "cmp",
            },
            routes = {
                {
                    filter = { event = "msg_show", find = "Hop .*:" },
                    opts = { skip = true }
                },
                {
                    view = "split",
                    filter = { event = "msg_show", min_height = 20 },
                },

            }
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            {
                "rcarriga/nvim-notify",
                keys = {
                    {
                        "<leader>nd",
                        function()
                            require("notify").dismiss({
                                pending = true,
                                silent = true,
                            })
                        end,
                        desc = "Notifications: Dismiss",
                    },
                },
                opts = { -- Animation style ()
                    stages = "slide",
                    fps = 60,

                    -- Function called when a new window is opened, use for changing win settings/config
                    on_open = nil,

                    -- Function called when a window is closed
                    on_close = nil,

                    -- Render function for notifications. See notify-render()
                    render = "default",

                    -- Default timeout for notifications
                    timeout = 5000,

                    -- For stages that change opacity this is treated as the highlight behind the window
                    -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
                    background_colour = "#000000",

                    -- Minimum width for notification windows
                    minimum_width = 50,

                    -- Icons for the different levels
                    icons = {
                        ERROR = "",
                        WARN = "",
                        INFO = "",
                        DEBUG = "",
                        TRACE = "✎",
                    },
                },
            },
        },
    },
}
