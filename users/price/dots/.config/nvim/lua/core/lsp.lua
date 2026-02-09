local M = {}

M.setup = function()
    vim.lsp.log.set_format_func(vim.inspect)
    vim.diagnostic.config({
        virtual_lines = true,
        virtual_text = false,
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

                        -- If for whatever reason the messages turn out to be empty, then don't emit
                        -- a message at all
                        if #messages == 0 then
                            return
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
        end,
    })

    -- Enable all language servers defined in `lsp/` & `after/lsp/`
    for _, dir in ipairs({
        "lsp",
        "after/lsp",
    }) do
        local lspcfg_dir = ("%s/%s"):format(vim.fn.stdpath("config"), dir)
        local fd = vim.uv.fs_scandir(lspcfg_dir)
        if fd then
            for lspcfg_file in
                function()
                    return vim.uv.fs_scandir_next(fd)
                end
            do
                local lsp_name = lspcfg_file:gsub(".lua\z", "")
                vim.lsp.enable(lsp_name)
            end
        end
    end
end

return M
