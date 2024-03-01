local M = {}

local augroup = vim.api.nvim_create_augroup("user-autocmds", { clear = false })
vim.api.nvim_create_autocmd("BufReadPre", {
    group = augroup,
    desc = "Ensure backupskip files do not leave anything behind",
    pattern = vim.opt.backupskip:get(),
    callback = function(args)
        ---@type integer
        local bufnr = args.buf

        vim.iter({
            "swapfile",
            "undofile",
        }):each(function(opt)
            vim.api.nvim_set_option_value(opt, false, {
                buf = bufnr,
            })
        end)
    end,
})

return M
