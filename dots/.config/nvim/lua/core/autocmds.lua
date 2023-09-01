local M = {}

M.setup = function()
    local augroup = vim.api.nvim_create_augroup("user-autocmds", { clear = true })
    -- NOTE: Highlight text yanked
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = augroup,
        callback = function()
            vim.highlight.on_yank()
        end,
    })

    -- NOTE: Remove trailing whitespace on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        command = "StripTrailSpace",
    })


    -- NOTE: Disables status column elements in Terminal buffer
    vim.api.nvim_create_autocmd("TermOpen", {
        group = augroup,
        callback = function()
            vim.api.nvim_set_option_value("statuscolumn", "", { scope = "local" })
            vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local" })
            vim.api.nvim_set_option_value("number", false, { scope = "local" })
            vim.api.nvim_set_option_value("relativenumber", false, { scope = "local" })
            vim.cmd.startinsert()
        end
    })
end

return M
