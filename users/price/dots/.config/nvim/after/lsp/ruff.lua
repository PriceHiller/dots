vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_stuff", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil or client.name ~= "ruff" then
            return
        end
        client.server_capabilities.hoverProvider = false
    end,
    desc = "LSP: Ruff Modifications",
})
return {}
