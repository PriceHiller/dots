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
            -- Key bind to allow rapidly toggling neo-tree. If the window is open and I need to to
            -- focus on it, I can just hit this twice which will toggle it closed then reopen
            -- neo-tree with it focused
            { "<D-A-x>", "<cmd>Neotree show toggle focus<cr>", desc = "Neotree: Toggle" },
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
            local snacks = require("snacks")
            local function on_move(data)
                snacks.rename.on_rename_file(data.source, data.destination)
            end
            local events = require("neo-tree.events")

            --- Compares two strings using natural ordering.
            --- @param a string The first string.
            --- @param b string The second string.
            --- @return boolean True if 'a' is strictly less than 'b'.
            local function natural_lt(a, b)
                local i, j = 1, 1
                local len_a, len_b = #a, #b

                local a_leading_nums = a:match("^%d+")
                local b_leading_nums = b:match("^%d+")

                if a_leading_nums and not b_leading_nums then
                    -- If `a` has any leading numbers while `b` lacks leading numbers, then we will
                    -- consider `a` > `b`
                    return true
                end

                while i <= len_a and j <= len_b do
                    local char_a = a:sub(i, i)
                    local char_b = b:sub(j, j)

                    -- Check if both characters are digits
                    local a_is_digit = char_a:match("%d")
                    local b_is_digit = char_b:match("%d")

                    if a_is_digit and b_is_digit then
                        -- Extract the complete number from both strings
                        local _, end_a, num_str_a = a:find("^(%d+)", i)
                        local _, end_b, num_str_b = b:find("^(%d+)", j)

                        local num_a = tonumber(num_str_a)
                        local num_b = tonumber(num_str_b)

                        -- Compare numeric values
                        if num_a ~= num_b then
                            return num_a < num_b
                        end

                        -- If values are equal, skip past the numbers and continue
                        i = end_a + 1
                        j = end_b + 1
                    else
                        if a_is_digit or b_is_digit then
                            -- If a doesn't have a digit then in this case,
                            -- a is considered > b
                            return a_is_digit
                        end

                        -- Standard character comparison
                        if char_a ~= char_b then
                            return char_a < char_b
                        end

                        i = i + 1
                        j = j + 1
                    end
                end

                -- If we reached the end, handle length differences (e.g., "a" < "abc")
                return len_a < len_b
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

                    return natural_lt(a_name, b_name)
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
                    { event = events.FILE_MOVED, handler = on_move },
                    { event = events.FILE_RENAMED, handler = on_move },
                },
            })
        end,
    },
}
