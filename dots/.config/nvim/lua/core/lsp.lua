local M = {}

M.setup = function()
    local function lspSymbol(name, icon)
        local hl = "DiagnosticSign" .. name
        vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
    end
    lspSymbol("Error", "󰅙")
    lspSymbol("Warn", "")
    lspSymbol("Info", "󰋼")
    lspSymbol("Hint", "")

    vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = true,
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
            numhl = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "",
                [vim.diagnostic.severity.HINT] = "",
            }
        },
        float = {
            focusable = true,
            style = "minimal",
            border = {
                " ",
                " ",
                " ",
                " ",
            },
            source = "always",
            header = "Diagnostic",
            prefix = "",
        },
    })
end

return M
