vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.log", "*_log", "*.LOG", "*_LOG" },
    command = "set ft=log",
})
