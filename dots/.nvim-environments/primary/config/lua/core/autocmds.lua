local M = {}

M.setup = function()
    -- NOTE: Highlight text yanked
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.highlight.on_yank()
        end,
    })

    -- NOTE: Remove trailing whitespace on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        command = "%s/\\s\\+$//e",
    })
end

return M
