local M = {}

M.setup = function()
    local function lspSymbol(name, icon, priority)
        local hl = "DiagnosticSign" .. name
        vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl, priority = priority })
    end

    lspSymbol("Error", "󰅙", 20)
    lspSymbol("Warn", "", 15)
    lspSymbol("Info", "󰋼", 10)
    lspSymbol("Hint", "", 10)

    vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = true,
        severity_sort = true,
        underline = true,
        update_in_insert = false,
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
