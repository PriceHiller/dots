vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attach_emmylua_modifications", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil or client.name ~= "emmylua_ls" then
            return
        end
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentOnTypeFormattingProvider = nil
        client.server_capabilities.documentRangeFormattingProvider = nil
    end,
    desc = "LSP: Emmylua Modifications",
})

return {
    ---@type lspconfig.settings.emmylua_ls
    settings = {
        emmylua = {
            runtime = {
                version = "LuaJIT",
            },
            hint = {
                enable = true,
                localHint = true,
            },
            completion = {
                callSnippet = true,
            },
        },
    },
}
