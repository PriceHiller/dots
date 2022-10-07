local M = {}

M.setup = function()
    vim.filetype.add({
        pattern = {
            [".*%.dockerfile"] = "dockerfile",
        },
    })
end

return M
