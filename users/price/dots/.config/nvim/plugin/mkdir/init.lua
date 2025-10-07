vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Automatically create nested directory if it doesn't exist",
    callback = function(_)
        local dir = vim.fn.expand("<afile>:p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
})
