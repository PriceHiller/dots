require("neogit").setup({
    disable_insert_on_commit = "auto",
    disable_commit_confirmation = true,
    use_telescope = true,
    integrations = {
        diffview = true,
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*Neogit*",
    callback = function ()
        vim.opt_local.list = false
    end
})
