local M = {}

M.setup = function()
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
