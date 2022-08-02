local loaded, neotree = pcall(require, "neo-tree")
if not loaded then
    return
end

vim.g.neo_tree_remove_legacy_commands = 1
neotree.setup({
    filesystem = {
        use_libuv_file_watcher = true,
    },
    window = {
        mappings = {
            ["/"] = "noop",
            ["/"] = {},
        },
    },
})
