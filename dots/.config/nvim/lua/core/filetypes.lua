local M = {}

M.setup = function()
    vim.filetype.add({
        filename = {
            [".dockerignore"] = "dockerignore",
        },
        pattern = {
            [".*%.dockerfile"] = "dockerfile",
            [".*/Azure%-Pipelines/.*%.yml"] = "azure-pipelines",
            [".*/Azure%-Pipelines/.*%.yaml"] = "azure-pipelines",
            [".*/waybar/config"] = "jsonc",
            [".*/etc/systemd/.*"] = "systemd",
            [".*%.psql"] = "sql"
        },
    })

    vim.treesitter.language.register("yaml", "azure-pipelines")
    vim.treesitter.language.register("gitignore", "dockerignore")
    vim.treesitter.language.register("html", "xml")
    vim.treesitter.language.register("sql", "psql")
end

return M
