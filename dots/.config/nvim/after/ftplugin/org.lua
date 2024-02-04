vim.opt_local.shiftwidth = 2
vim.opt_local.modeline = true
vim.opt_local.wrap = false
vim.opt_local.conceallevel = 1
-- HACK: Correctly handle treesitter attachment. Without this folds and reformatting fall out of
-- sync and treesitter can fail to properly parse the buffer on content modifications.
if not vim.b.org_did_edit then
    vim.b.org_did_edit = true
    vim.defer_fn(vim.schedule_wrap(function()
        vim.cmd.edit()
    end), 10)
end
