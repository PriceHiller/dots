return {
    {
        "OXY2DEV/ui.nvim",
        lazy = false,
        keys = {
            {
                "<leader>nd",
                function()
                    vim.cmd("UI Clear")
                end,
                desc = "Notifications: Dismiss",
            },
            {
                "<leader>nv",
                function()
                    vim.cmd.messages()
                end,
                desc = "Notifications: View",
            },
        },
        init = function()
            vim.opt.cmdheight = 0
        end,
        config = function()
            local progress_parts = {
                "",
                "",
                "",
                "",
                "",
                "",
            }

            local prog = 1
            local is_updating = false
            local next_prog_part = function()
                local prog_spinner = progress_parts[prog]
                if not is_updating then
                    is_updating = true
                    vim.defer_fn(function()
                        prog = (prog % #progress_parts) + 1
                        is_updating = false
                    end, 80)
                end
                return prog_spinner
            end

            -- Integrate with blink.cmp
            vim.api.nvim_create_autocmd({ "VimResized", "VimEnter", "CmdlineEnter" }, {
                callback = function()
                    vim.g.ui_cmdline_pos = {  vim.o.lines - 1, 0 }
                end,
            })

            require("ui").setup({
                popupmenu = {
                    enable = false,
                },

                cmdline = {
                    enable = false,
                },

                message = {
                    history_prefence = "internal",
                    msg_styles = {
                        lsp_progress_undone = {
                            condition = function(entry, _, _)
                                return entry.kind == "lsp-progress-undone"
                            end,
                            decorations = function(_, _, _)
                                return {
                                    icon = {
                                        { "▍", "Special" },
                                        { next_prog_part(), "LspProgress.spinner.undone" },
                                        { " ", "" },
                                    },
                                }
                            end,
                        },
                        lsp_progress_done = {
                            condition = function(entry, _, _)
                                return entry.kind == "lsp-progress-done"
                            end,
                            duration = 1000,
                            decorations = {
                                icon = { { "▍", "Special" }, { "", "LspProgress.spinner.done" }, { " ", "" } },
                            },
                        },
                    },
                },
            })

            vim.api.nvim_create_autocmd("LspProgress", {
                callback = function(args)
                    ---@type integer
                    local client_id = args.data.client_id
                    local client = vim.lsp.get_client_by_id(client_id)
                    if not client then
                        return
                    end

                    for progress in client.progress do
                        local value = progress.value
                        if type(value) == "table" and value.kind then
                            local percentage = value.percentage
                            local done = percentage == 100
                            vim.api.nvim_echo(
                                {
                                    { client.name, done and "LspProgress.client.done" or "LspProgress.client.undone" },
                                    { " ", "" },
                                    { value.title, done and "LspProgress.title.done" or "LspProgress.title.undone" },
                                    { " ", "" },
                                    percentage
                                            and {
                                                ("(%d%%)"):format(percentage),
                                                "LspProgress.percentage.done" or "LspProgress.percentage.undone",
                                            }
                                        or { "" },
                                    { value.message and " [" .. value.message .. "] " or "", "LspProgress.message" },
                                },
                                false,
                                {
                                    kind = (done or not percentage) and "lsp-progress-done" or "lsp-progress-undone",
                                }
                            )
                        end
                    end
                end,
            })
        end,
    },
}
