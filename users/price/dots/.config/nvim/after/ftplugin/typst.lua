vim.opt_local.textwidth = 0
vim.opt_local.shiftwidth = 2
vim.api.nvim_set_hl(
    0,
    "@markup.heading.typst",
    vim.tbl_deep_extend(
        "force",
        vim.api.nvim_get_hl(0, { name = "@markup.heading", link = false }),
        { underline = true, bold = true }
    )
)

vim.keymap.set("n", "<localleader>fr", function()
    local buf = vim.api.nvim_get_current_buf()
    local fpath = vim.api.nvim_buf_get_name(buf)
    local pdf_path = vim.fn.fnamemodify(fpath, ":r") .. ".pdf"
    vim.system({ "xdg-open", pdf_path }, { detach = true })
end, {
    buffer = true,
    silent = true,
})
