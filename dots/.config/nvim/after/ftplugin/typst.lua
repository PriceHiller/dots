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
