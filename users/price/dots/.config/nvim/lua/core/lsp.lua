local M = {}

M.setup = function()
    vim.lsp.log.set_format_func(vim.inspect)
    vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "󰅙",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "󰋼",
                [vim.diagnostic.severity.HINT] = "",
            },
            linehl = {
                [vim.diagnostic.severity.ERROR] = "CustomErrorBg",
            },
        },
        float = {
            focusable = true,
            style = "minimal",
            border = "solid",
            source = "if_many",
            prefix = "",
        },
    })
    local client_notif_timer = vim.uv.new_timer()
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client then
                return
            end
            if not client_notif_timer then
                vim.notify(
                    "Failed to create LSP client notification timer!\nWill *not* emit bulk notifications for newly attached clients!",
                    vim.log.levels.WARN
                )
                vim.notify(("Attached `%s` language server"):format(client.name))
            elseif not client_notif_timer:is_active() then
                local last_clients = {}
                client_notif_timer:start(
                    100,
                    0,
                    vim.schedule_wrap(function()
                        client_notif_timer:stop()
                        local cur_clients = vim.lsp.get_clients({ bufnr = bufnr })
                        if #cur_clients > #last_clients then
                            last_clients = cur_clients
                        end
                        local messages = {}
                        for _, cur_client in ipairs(cur_clients) do
                            local client_name = vim.trim(cur_client.name)
                            if client_name ~= "" then
                                table.insert(messages, "- `" .. cur_client.name .. "`")
                            end
                        end

                        vim.notify(table.concat(messages, "\n"), vim.log.levels.INFO, {
                            title = "Attached Language Servers",
                            ---@param win integer The window handle
                            on_open = function(win)
                                vim.bo[vim.api.nvim_win_get_buf(win)].filetype = "markdown"
                            end,
                        })
                    end)
                )
            end

            local server_capabilities = client.server_capabilities
            if not server_capabilities then
                return
            end

            if vim.list_contains({
                "lua_ls",
            }, client.name) then
                server_capabilities.documentFormattingProvider = false
                server_capabilities.documentRangeFormattingProvider = false
            end

            if server_capabilities.inlayHintProvider and not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
        end,
    })
end

return M
