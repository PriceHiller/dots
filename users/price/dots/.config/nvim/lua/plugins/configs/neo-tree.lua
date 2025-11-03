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
        lazy = false,
        cmd = "Neotree",
        keys = {
            { "<leader>nt", "<cmd>Neotree show toggle focus<cr>", desc = "Neotree: Toggle" },
        },
        init = function()
            -- Correctly hijack netrw, thanks to
            -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1247#issuecomment-1836294271
            vim.api.nvim_create_autocmd({ "VimEnter", "BufAdd" }, {
                desc = "Lazy loads neo-tree when opening a directory",
                once = true,
                callback = function(args)
                    local stats = vim.uv.fs_stat(args.file)
                    if stats and stats.type == "directory" then
                        vim.api.nvim_set_current_dir(args.file)
                        vim.wait(1000, function()
                            return vim.v.vim_did_enter == 1
                        end, 5)
                        require("neo-tree.command").execute({
                            action = "focus",
                            source = "filesystem",
                            reveal_file = args.file,
                        })
                    end
                    return true
                end,
            })
        end,
        config = function()
            ---@class Ext.Neotree.ExtractedSortKey
            ---@field type "text" | "date" | "number"
            ---@field value integer | string

            ---@param name string
            ---@return Ext.Neotree.ExtractedSortKey
            local function extract_sort_key(name)
                -- Extract first token (before space, underscore, or dash)
                local prefix = name:match("^([^%s_%-]+)")
                if not prefix then
                    return { type = "text", value = name }
                end

                -- Try to parse as date/datetime (YYYY-MM-DD, YYYYMMDD, YYYY/MM/DD, etc.)
                local y, m, d = prefix:match("^(%d%d%d%d)[/-]?(%d%d)[/-]?(%d%d)")
                if y then
                    -- Check for time component
                    local h, min, s = name:match("^[^%s_%-]+[%s_%-]+(%d%d):?(%d%d):?(%d?%d?)")
                    h, min, s = tonumber(h) or 0, tonumber(min) or 0, tonumber(s) or 0

                    local timestamp = os.time({
                        ---@diagnostic disable-next-line: assign-type-mismatch
                        year = tonumber(y),
                        ---@diagnostic disable-next-line: assign-type-mismatch
                        month = tonumber(m),
                        ---@diagnostic disable-next-line: assign-type-mismatch
                        day = tonumber(d),
                        hour = h,
                        min = min,
                        sec = s,
                    })
                    return { type = "date", value = timestamp }
                end

                -- Try to parse as number (including decimals)
                local num = tonumber(prefix)
                if num then
                    return { type = "number", value = num }
                end

                -- Default to alphabetic
                return { type = "text", value = prefix }
            end

            ---@class ExtNeotree.SortItem
            ---@field name? string
            ---@field path string
            ---@field type "directory" | "file"

            require("neo-tree").setup({
                --- Sorts in descending priority if the type of entires are different:
                ---
                --- - Date
                --- - Number
                --- - Name
                ---
                ---@param a ExtNeotree.SortItem
                ---@param b ExtNeotree.SortItem
                ---@return boolean?
                sort_function = function(a, b)
                    if a.type ~= b.type then
                        return a.type < b.type
                    end

                    local a_name = a.name and a.name or a.path
                    local b_name = b.name and b.name or b.path

                    local key_a = extract_sort_key(a_name)
                    local key_b = extract_sort_key(b_name)

                    -- Type priority: date > number > text
                    local type_priority = { date = 3, number = 2, text = 1 }
                    local priority_a = type_priority[key_a.type]
                    local priority_b = type_priority[key_b.type]

                    if priority_a ~= priority_b then
                        return priority_a > priority_b
                    end

                    -- Same type, compare values
                    if key_a.value ~= key_b.value then
                        return key_a.value < key_b.value
                    end

                    -- If prefixes are equal, compare full names
                    return a_name:lower() < b_name:lower()
                end,
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
                    window = {
                        mappings = {
                            ["<C-CR>"] = {
                                ---@diagnostic disable-next-line: assign-type-mismatch
                                function(state)
                                    local node = state.tree:get_node()
                                    local path = node.path
                                    local dir = vim.fn.fnamemodify(path, ":p")
                                    if vim.fn.isdirectory(dir) == 0 then
                                        dir = vim.fn.fnamemodify(path, ":h")
                                    end
                                    require("oil").open_float(dir)
                                end,
                            },
                        },
                    },
                },
                window = {
                    position = "left",
                    relative = "editor",
                    mappings = {
                        ["<space>"] = "none",
                        ["/"] = "none",
                        ["f"] = "none",
                    },
                },
                event_handlers = {
                    {
                        event = "neo_tree_window_after_open",
                        handler = function(args)
                            vim.wo[args.winid].winfixheight = false
                        end,
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
