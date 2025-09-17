vim.opt_local.shiftwidth = 2
vim.opt_local.modeline = true
vim.keymap.set("n", "<localleader>ff", function()
    vim.cmd([[Org indent_mode]])
end, {
    buffer = true,
    desc = "Org: Toggle Indent Mode",
})

local FormatPat = require("utils.formatpat").new()
local List = require("utils.list")

FormatPat.pat = List.prepend(FormatPat.pat, {
    [=[- \[.\{0,1\}\]]=],
})
vim.opt_local.formatlistpat = FormatPat:listpat()
