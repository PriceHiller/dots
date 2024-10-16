local M = {}
M.setup = function()
    local disabled_built_ins = {
        "gzip",
        "zip",
        "zipPlugin",
        "tar",
        "tarPlugin",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "matchit",
    }

    for _, plugin in pairs(disabled_built_ins) do
        vim.g["loaded_" .. plugin] = 1
    end
end

return M
