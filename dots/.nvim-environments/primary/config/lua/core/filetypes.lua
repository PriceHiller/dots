local M = {}

M.setup = function()
    vim.filetype.add({
        pattern = {
            [".*%.dockerfile"] = "dockerfile",
            [".*%.dockerignore"] = "gitignore"
        },
    })
end

return M
