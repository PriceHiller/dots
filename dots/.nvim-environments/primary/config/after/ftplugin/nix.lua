local opt_local = vim.opt_local

opt_local.tabstop = 2
opt_local.shiftwidth = 2

vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
