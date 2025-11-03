vim.opt_local.textwidth = 0
vim.opt_local.shiftwidth = 2

vim.keymap.set("n", "<localleader>fr", function()
    local buf = vim.api.nvim_get_current_buf()
    local fpath = vim.api.nvim_buf_get_name(buf)
    local pdf_path = vim.fn.fnamemodify(fpath, ":r") .. ".pdf"
    vim.system({ "xdg-open", pdf_path }, { detach = true })
end, {
    buffer = true,
    silent = true,
})

local FormatPat = require("utils.formatpat").new()
local List = require("utils.list")

FormatPat.pat = List.prepend(FormatPat.pat, { [[=\+]] })
vim.opt_local.formatlistpat = FormatPat:listpat()
