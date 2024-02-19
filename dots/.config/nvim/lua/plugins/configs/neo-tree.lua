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
                once = true,
                callback = function()
                    local f = vim.fn.expand("%:p")
                    if vim.fn.isdirectory(f) == 1 then
                        require("neo-tree")
                        return true
                    end
                end,
            })
        end,
        opts = function()
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
