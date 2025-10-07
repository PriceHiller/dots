vim.api.nvim_create_autocmd("FocusLost", {
    command = "silent! update",
    desc = "Auto-save on focus lost"
})
