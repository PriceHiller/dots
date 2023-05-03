local neorg = require("neorg")

neorg.setup({
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {
            config = {
                dim_code_blocks = {
                    enabled = true,
                    content_only = true,
                    adaptive = true,
                },
                icon_preset = "diamond",
            },
        },
        ["core.esupports.metagen"] = {
            config = {
                type = "auto",
            },
        },
        ["core.integrations.nvim-cmp"] = {
            config = {},
        },
        ["core.completion"] = {
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
        ["core.dirman"] = {
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
        ["core.qol.toc"] = {},
    },
})