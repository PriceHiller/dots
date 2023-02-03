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

    -- NOTE: Remember folds
    vim.api.nvim_create_augroup("SaveFolds", { clear = true })
    vim.api.nvim_create_autocmd("BufWinLeave", {
        pattern = "*.*",
        command = "mkview",
        group = "SaveFolds"
    })
    vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "*.*",
        command = "silent! loadview",
        group = "SaveFolds"
    })

end

return M
