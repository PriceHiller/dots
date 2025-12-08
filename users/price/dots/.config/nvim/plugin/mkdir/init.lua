vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Automatically create nested directory if it doesn't exist",
    callback = function(args)
        local dir = vim.fn.expand("<afile>:p:h")

        local bufnr = args.buf
        if not vim.bo[bufnr].buflisted then
            -- Ignore unlisted buffers
            return
        end

        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
})
