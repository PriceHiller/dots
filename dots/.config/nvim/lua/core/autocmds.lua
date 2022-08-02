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

    -- -- NOTE: Handles scenarios in which the filetype isn't detected on load
    -- vim.api.nvim_create_autocmd('BufReadPost', {
    --     pattern = '*',
    --     callback = function()
    --         local opt_ft = vim.opt_local.ft:get()
    --         if opt_ft == nil or opt_ft == '' then
    --             vim.cmd('filetype detect')
    --         end
    --     end,
    -- })

    -- NOTE: Local cursorline
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
            vim.opt_local.cursorline = true
        end,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
        pattern = "*",
        callback = function()
            vim.opt_local.cursorline = true
        end,
    })

    vim.api.nvim_create_autocmd("WinLeave", {
        pattern = "*",
        callback = function()
            vim.opt_local.cursorline = false
        end,
    })
end

return M
