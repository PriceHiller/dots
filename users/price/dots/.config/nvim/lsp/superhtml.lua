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
