local neogit = require("neogit")
neogit.setup({
    disable_insert_on_commit = "auto",
    disable_commit_confirmation = true,
    integrations = {
        diffview = true,
        telescope = true,
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*Neogit*",
    callback = function()
        vim.opt_local.list = false
    end,
})
