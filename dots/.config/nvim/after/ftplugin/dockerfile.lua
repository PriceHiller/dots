local file_loc = vim.fn.expand("%:p:h")

vim.opt_local.makeprg = "docker build " .. file_loc

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    callback = function()
        require("lint").try_lint()
    end,
})
