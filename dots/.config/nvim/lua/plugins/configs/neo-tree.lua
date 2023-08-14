return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        cmd = "Neotree",
        keys = {
            { "<leader>nt", "<cmd>Neotree show toggle focus<cr>", desc = "Neotree: Toggle" },
        },
        opts = function()
            vim.g.neo_tree_remove_legacy_commands = 1

            return {
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
            }
        end,
    },
}
