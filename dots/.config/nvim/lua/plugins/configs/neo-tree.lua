return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "miversen33/netman.nvim",
        },
        cmd = "Neotree",
        keys = {
            { "<leader>nt", "<cmd>Neotree show toggle focus<cr>", desc = "Neotree: Toggle" },
        },
        init = function()
            -- Correctly hijack netrw, thanks to
            -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1247#issuecomment-1836294271
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("NeoTreeInit", { clear = true }),
                callback = function()
                    local f = vim.fn.expand("%:p")
                    if vim.fn.isdirectory(f) ~= 0 then
                        vim.cmd("Neotree current dir=" .. f)
                        -- neo-tree is loaded now, delete the init autocmd
                        vim.api.nvim_clear_autocmds({ group = "NeoTreeInit" })
                    end
                end,
            })
        end,
        opts = function()
            vim.g.neo_tree_remove_legacy_commands = 1

            return {
                sources = {
                    "filesystem",
                    "git_status",
                    "buffers",
                    "netman.ui.neo-tree",
                },
                source_selector = {
                    winbar = true,
                    sources = {
                        {
                            source = "filesystem",
                        },
                        {
                            source = "buffers",
                        },
                        {
                            source = "remote",
                        },
                    },
                },
                filesystem = {
                    use_libuv_file_watcher = true,
                    hijack_netrw_behavior = "open_current",
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
