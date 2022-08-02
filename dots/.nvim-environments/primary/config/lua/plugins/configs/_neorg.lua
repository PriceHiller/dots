local loaded, neorg = pcall(require, "neorg")
if not loaded then
    return
end

neorg.setup({
    load = {
        ["core.defaults"] = {},
        ["core.norg.concealer"] = {},
        ["core.norg.esupports.metagen"] = {
            config = {
                type = "auto",
            },
        },
        ["core.integrations.nvim-cmp"] = {
            config = {},
        },
        ["core.norg.completion"] = {
            config = {
                engine = "nvim-cmp",
            },
        },
        ["core.keybinds"] = {
            config = {
                default_keybinds = true,
                -- norg_leader = "-"
            },
        },
        ["core.norg.dirman"] = {
            config = {
                workspaces = {
                    default = "~/.notes", -- Format: <name_of_workspace> = <path_to_workspace_root>
                },
                autochdir = true, -- Automatically change the directory to the current workspace's root every time
                index = "index.norg", -- The name of the main (root) .norg file
                last_workspace = vim.fn.stdpath("cache") .. "/neorg_last_workspace.txt", -- The location to write and read the workspace cache file
            },
        },
        ["core.integrations.telescope"] = {},
        ["core.norg.qol.toc"] = {},
        ["core.gtd.base"] = {
            config = {
                workspace = "default",
            },
        },
        ["core.gtd.ui"] = {
            config = {},
        },
        ["core.gtd.helpers"] = {
            config = {},
        },
    },
})
