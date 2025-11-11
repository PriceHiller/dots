vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "superhtml" then
            return
        end

        -- Disable formatting
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        client.server_capabilities.documentOnTypeFormattingProvider = nil
    end,
    desc = "LSP: Super HTML Modifications",
})

local original_diag_set = vim.diagnostic.set

---@param namespace integer The diagnostic namespace
---@param bufnr integer Buffer number
---@param diagnostics vim.Diagnostic.Set[]
---@param opts? vim.diagnostic.Opts Display options to pass to |vim.diagnostic.show()|
---@diagnostic disable-next-line: duplicate-set-field
vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
    ---@type vim.Diagnostic.Set[]
    local diags = {}
    for _, diag in ipairs(diagnostics) do
        if diag.code ~= "html_elements_cant_self_close" then
            table.insert(diags, diag)
        end
    end

    original_diag_set(namespace, bufnr, diags, opts)
end

return {}
