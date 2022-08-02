local M = {}
local util = require("utils.funcs")

M.setup = function()
    vim.g.tokyonight_style = "night"
    vim.g.tokyonight_transparent = true
    vim.g.tokyonight_transparent_sidebar = true

    local colorscheme_name = "kanagawa"
    local loaded, _ = pcall(vim.cmd, "colorscheme " .. colorscheme_name)

    if not loaded then
        vim.notify('Colorscheme "' .. colorscheme_name .. '" could not be loaded!', vim.lsp.log_levels.WARN, {
            title = "Colorscheme",
        })
    end

    -- vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#61AFEF" })
end
return M
