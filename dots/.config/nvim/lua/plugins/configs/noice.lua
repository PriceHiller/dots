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
                    opts = { skip = true },
                },
                -- Ignore `written` message
                {
                    filter = { event = "msg_show", find = '^".*" %d*L, %d*B written$' },
                    opts = { skip = true },
                },
                -- Ignore `undo` message
                {
                    filter = { event = "msg_show", find = "^%d+ .*; before #%d+  %d+.*ago$" },
                    opts = { skip = true },
                },
                -- Ignore `redo` message
                {
                    filter = { event = "msg_show", find = "^%d+ .*; after #%d+  %d+.*ago$" },
                    opts = { skip = true },
                },
                {
                    view = "split",
                    filter = { event = "msg_show", min_height = 20 },
                },
            },
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            {
                "rcarriga/nvim-notify",
                keys = {
                    {
                        "<leader>nd",
                        function()
                            vim.cmd.noh()
                            require("notify").dismiss({
                                pending = true,
                                silent = true,
                            })
                        end,
                        desc = "Notifications: Dismiss",
                    },
                },
                config = function()
                    local base = require("notify.render.base")

                    local opts = {
                        stages = "slide",
                        fps = 60,
                        on_open = function(win)
                            local buf = vim.api.nvim_win_get_buf(win)
                            local ft = vim.bo[buf].filetype
                            if ft == "" or ft == "notify" then
                                vim.api.nvim_set_option_value(
                                    "filetype",
                                    "markdown",
                                    { buf = vim.api.nvim_win_get_buf(win) }
                                )
                            vim.api.nvim_set_option_value("wrap", true, { win = win })
                            end
                        end,
                        render = function(bufnr, notif, highlights, _)
                            local left_icon = notif.icon .. " "
                            local max_message_width = math.max(math.max(unpack(vim.tbl_map(function(line)
                                return vim.fn.strchars(line)
                            end, notif.message))))
                            local right_title = notif.title[2]
                            local left_title = notif.title[1]
                            local title_accum = vim.str_utfindex(left_icon)
                                + vim.str_utfindex(right_title)
                                + vim.str_utfindex(left_title)

                            local left_buffer = string.rep(" ", math.max(0, max_message_width - title_accum))

                            local namespace = base.namespace()
                            vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { "", "" })
                            vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
                                virt_text = {
                                    { left_icon, highlights.icon },
                                    { left_title .. left_buffer, highlights.title },
                                },
                                virt_text_win_col = 0,
                                priority = 10,
                            })
                            vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
                                virt_text = { { right_title, highlights.title } },
                                virt_text_pos = "right_align",
                                priority = 10,
                            })
                            vim.api.nvim_buf_set_lines(bufnr, 1, -1, false, notif.message)

                            vim.api.nvim_buf_set_extmark(bufnr, namespace, 1, 0, {
                                hl_group = highlights.body,
                                end_line = #notif.message,
                                end_col = #notif.message[#notif.message],
                                priority = 50, -- Allow treesitter to override
                            })
                        end,

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
                    }
                    require("notify").setup(opts)
                end,
            },
        },
    },
}
