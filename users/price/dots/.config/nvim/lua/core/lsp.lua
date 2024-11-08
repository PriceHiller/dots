local M = {}

M.setup = function()
    -- HACK: See https://github.com/neovim/neovim/issues/30985#issuecomment-2447329525
    -- This fixes an issue with "server cancelled the request" emissions from `rust-analyzer`
    for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
        local default_diagnostic_handler = vim.lsp.handlers[method]
        vim.lsp.handlers[method] = function(error, result, ctx, config)
            if error ~= nil and error.code == -32802 then
                return
            end
            return default_diagnostic_handler(error, result, ctx, config)
        end
    end
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
end

return M
