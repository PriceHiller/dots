local M = {}

M.setup = function()
    vim.filetype.add({
        filename = {
            ['.dockerignore'] = "dockerignore"
        },
        pattern = {
            [".*%.dockerfile"] = "dockerfile",
            [".*/Azure%-Pipelines/.*%.yml"] = "azure-pipelines",
            [".*/Azure%-Pipelines/.*%.yaml"] = "azure-pipelines",
        },
    })

    vim.treesitter.language.register("yaml", "azure-pipelines")
    vim.treesitter.language.register("gitignore", "dockerignore")
end

return M
