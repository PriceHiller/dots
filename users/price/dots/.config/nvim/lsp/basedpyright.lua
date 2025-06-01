vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_disable_pyright_stuff", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil or client.name ~= "basedpyright" then
            return
        end
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentOnTypeFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end,
    desc = "LSP: Pyright Modifications",
})
return {
    settings = {
        pyright = {
            disableOrganizeImports = true,
        },
        basedpyright = {
            analysis = {
                diagnosticSeverityOverrides = {
                    reportAny = false,
                    reportExplicitAny = false,
                },
            },
        },
    },
}
