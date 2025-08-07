vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.tf", "*tfvars"},
    command = "set ft=terraform"
})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.hcl", ".terraformrc", "terraform.rc"},
    command = "set ft=hcl"
})


vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.tfstate", "*.tfstate.backup"},
    command = "set ft=jsosn"
})
