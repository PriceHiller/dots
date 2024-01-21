vim.opt_local.shiftwidth = 2
vim.api.nvim_set_hl(
    0,
    "@text.title.typst",
    vim.tbl_deep_extend(
        "force",
        vim.api.nvim_get_hl(0, { name = "@text.title.typst", link = false }),
        { underline = true, bold = true }
    )
)
