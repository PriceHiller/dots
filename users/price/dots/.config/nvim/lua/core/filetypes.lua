local M = {}

M.setup = function()
    vim.filetype.add({
        filename = {
            [".dockerignore"] = "dockerignore",
            [".envrc"] = "sh",
        },
        pattern = {
            [".*%.dockerfile"] = "dockerfile",
            [".*/Azure%-Pipelines/.*%.yml"] = "azure-pipelines",
            [".*/Azure%-Pipelines/.*%.yaml"] = "azure-pipelines",
            [".*/waybar/config"] = "jsonc",
            [".*/etc/systemd/.*"] = "systemd",
        },
    })

    ---Maps a given file type to a treesitter language to use for the given file type
    ---@type table<string, string>
    local fts_to_lang_registration = {
        ["azure-pipelines"] = "yaml",
        ["dockerignore"] = "gitignore",
        ["zsh"] = "bash",
    }

    vim.iter(fts_to_lang_registration):each(function(filetype, language)
        vim.treesitter.language.register(language, filetype)
    end)
end

return M
