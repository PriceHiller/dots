local neotree = require("neo-tree")

vim.g.neo_tree_remove_legacy_commands = 1
neotree.setup({
    source_selector = {
        winbar = true,
    },
    filesystem = {
        use_libuv_file_watcher = true,
    },
    window = {
        mappings = {
            ["<space>"] = "none",
            ["/"] = "none",
        },
    },
})
