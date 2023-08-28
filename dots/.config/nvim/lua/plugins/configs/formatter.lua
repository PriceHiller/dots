return {
    {
        "mhartington/formatter.nvim",
        keys = {
            {
                "<leader>lf",
                function()
                    local active_clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" })
                    if #active_clients > 0 then
                        vim.lsp.buf.format({ async = true })
                    else
                        vim.cmd.Format()
                    end
                end,
                -- I know this is a lie below, but I'm used to the key being LSP bound, so fuck it
                desc = "LSP: Format",
            },
        },
        opts = function()
            local filetypes = require("formatter.filetypes")
            return {
                logging = true,
                log_level = vim.log.levels.WARN,
                filetype = {
                    markdown = filetypes.markdown.prettierd,
                },
            }
        end,
    },
}
