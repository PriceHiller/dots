local M = {}

M.setup = function()
    local function lspSymbol(name, icon)
        local hl = "DiagnosticSign" .. name
        vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
    end

    lspSymbol("Error", "")
    lspSymbol("Warn", "")
    lspSymbol("Info", "")
    lspSymbol("Hint", "")

    local border = {
        { "╭", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╮", "FloatBorder" },
        { "│", "FloatBorder" },
        { "╯", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╰", "FloatBorder" },
        { "│", "FloatBorder" },
    }

    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    vim.diagnostic.config({
        virtual_text = false,
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
