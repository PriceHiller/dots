return {
    {
        "m-demare/hlargs.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- Detach hlargs if the LSP server provides semantic tokens
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then
                        return
                    end
                    local server_capabilities = client.server_capabilities
                    if not server_capabilities then
                        return
                    end

                    if
                        server_capabilities.semanticTokensProvider
                        and server_capabilities.semanticTokensProvider.full
                    then
                        require("hlargs").disable_buf(args.buf)
                    end
                end,
            })

            require("hlargs").setup()
        end,
    },
}
