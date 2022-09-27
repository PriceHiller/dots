local M = {}

M.setup = function()
    local function lspSymbol(name, icon, linehlbg)
        local hl = "DiagnosticSign" .. name
        -- local linehl = 'DiagnosticSignLineHl' .. name
        -- vim.api.nvim_set_hl(0, linehl, {
        --     bg = linehlbg,
        -- })
        vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl, linehl = linehl })
    end

    lspSymbol("Error", "", "#2d202a")
    lspSymbol("Warn", "", "#2e2a2d")
    lspSymbol("Info", "", "#192b38")
    lspSymbol("Hint", "", "#1a2b32")

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
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    })
end

return M
