vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "miversen33/netman.nvim",
            "folke/snacks.nvim",
        },
        cmd = "Neotree",
        keys = {
            { "<leader>nt", "<cmd>Neotree show toggle focus<cr>", desc = "Neotree: Toggle" },
        },
        init = function()
            -- Correctly hijack netrw, thanks to
            -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1247#issuecomment-1836294271
            vim.api.nvim_create_autocmd("BufEnter", {
                desc = "Lazy loads neo-tree when opening a directory",
                callback = function(args)
                    local stats = vim.uv.fs_stat(args.file)
                    if stats and stats.type == "directory" then
                        require("neo-tree")
                        return true
                    end
                end,
            })
            vim.api.nvim_create_autocmd("DirChanged", {
                desc = "Show neo-tree on directory changes",
                callback = function()
                    vim.cmd("Neotree show")
                end,
            })
        end,
        config = function()
            require("neo-tree").setup({
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
                            source = "git_status",
                        },
                        {
                            source = "remote",
                            display_name = " Remote",
                        },
                    },
                },
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = false,
                    },
                    use_libuv_file_watcher = true,
                    filtered_items = {
                        visible = true,
                    },
                },
                window = {
                    mappings = {
                        ["<space>"] = "none",
                        ["/"] = "none",
                        ["f"] = "none",
                        ["F"] = "fuzzy_finder",
                    },
                },
            })
        end,
        opts = function(_, opts)
            local snacks = require("snacks")
            local function on_move(data)
                snacks.rename.on_rename_file(data.source, data.destination)
            end
            local events = require("neo-tree.events")
            opts.event_handlers = opts.event_handlers or {}
            vim.list_extend(opts.event_handlers, {
                { event = events.FILE_MOVED, handler = on_move },
                { event = events.FILE_RENAMED, handler = on_move },
            })
        end,
    },
}
