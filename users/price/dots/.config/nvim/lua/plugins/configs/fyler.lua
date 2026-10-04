vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

---@param instance fyler.Finder
---@param direction integer
---@param expand_directories boolean|nil
---@return nil
local function move_git_file(instance, direction, expand_directories)
    expand_directories = expand_directories or true

    local ns = vim.api.nvim_get_namespaces()["FylerFinderBuf" .. instance.buf_id]
    if not ns then
        return
    end

    local visible = instance.state:to_lines(instance.cache.ui.hidden_items)
    local changed_rows = {}

    for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(instance.buf_id, ns, 0, -1, { details = true })) do
        local details = mark[4]
        local group = details and details.hl_group
        local row = mark[2]

        if type(group) == "string" and group:match("^FylerGit") then
            local entry = visible[row + 1]
            if entry then
                changed_rows[row] = entry
            end
        end
    end

    local cursor_row = vim.api.nvim_win_get_cursor(instance.win_id)[1] - 1
    local last_row = #visible - 1

    ---@param row integer 0-based rendered row
    ---@return boolean whether navigation or expansion was started
    local function visit(row)
        local entry = changed_rows[row]
        if not entry then
            return false
        end

        if entry.type == "directory" then
            if not expand_directories or entry.expanded then
                return false
            end

            -- Git status is propagated to closed directories. Expand the next
            -- such directory and retry after its contents have been rendered.
            local current = require("fyler.finder").parse_cursor_line(instance)
            local current_path = current and current.path

            instance.state:toggle(entry.path, true)
            instance:refresh({
                target_path = entry.path,
                recursive = true,
                callback = function()
                    -- The Git extension adds its extmarks later in this same
                    -- refresh, so retry on the next scheduled turn.
                    vim.schedule(function()
                        if not instance.win_id or not vim.api.nvim_win_is_valid(instance.win_id) then
                            return
                        end

                        local refreshed = instance.state:to_lines(instance.cache.ui.hidden_items)
                        if current_path then
                            for index, item in ipairs(refreshed) do
                                if item.path == current_path then
                                    vim.api.nvim_win_set_cursor(instance.win_id, { index, 0 })
                                    break
                                end
                            end
                        end

                        move_git_file(instance, direction, expand_directories)
                    end)
                end,
            })
            return true
        end

        instance:follow({ target_path = entry.path })
        return true
    end

    if direction > 0 then
        for row = cursor_row + 1, last_row do
            if visit(row) then
                return
            end
        end
        for row = 0, cursor_row do
            if visit(row) then
                return
            end
        end
    else
        for row = cursor_row - 1, 0, -1 do
            if visit(row) then
                return
            end
        end
        for row = last_row, cursor_row, -1 do
            if visit(row) then
                return
            end
        end
    end

    vim.notify("No visible changed files", vim.log.levels.INFO)
end

---@param instance fyler.Finder
---@return nil
local function open_directory_in_oil(instance)
    local node = require("fyler.finder").parse_cursor_line(instance)
    if not node then
        return
    end

    local dir = vim.fn.fnamemodify(node.path, ":p")
    if vim.fn.isdirectory(dir) == 0 then
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    require("oil").open_float(dir)
end

---@param instance fyler.Finder
---@return nil
local function next_changed_git_file(instance)
    move_git_file(instance, 1)
end

---@param instance fyler.Finder
---@return nil
local function previous_changed_git_file(instance)
    move_git_file(instance, -1)
end

---@param instance fyler.Finder
---@return nil
local function next_visible_changed_git_file(instance)
    move_git_file(instance, 1, false)
end

---@param instance fyler.Finder
---@return nil
local function previous_visible_changed_git_file(instance)
    move_git_file(instance, -1, false)
end

return {
    {
        "FylerOrg/fyler.nvim",
        cmd = "Fyler",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/snacks.nvim",
            "stevearc/oil.nvim",
        },
        keys = {
            {
                "<leader>nt",
                function()
                    require("fyler").toggle()
                end,
                desc = "Fyler: Toggle",
            },
            -- Toggling twice closes the finder and reopens it focused.
            {
                "<D-A-x>",
                function()
                    require("fyler").toggle()
                end,
                desc = "Fyler: Toggle",
            },
        },
        config = function()
            require("fyler").setup({
                auto_confirm_simple_mutation = true,
                kind = "split_left_most",
                kind_presets = {
                    split_left_most = {
                        width = 32,
                    },
                },
                use_as_default_explorer = true,
                follow_current_file = true,
                -- Let Neovim's cwd drive Fyler, not the other way around.
                follow_root_dir = false,
                extensions = {
                    git = { enabled = true },
                    watcher = { enabled = true },
                },
                hooks = {
                    ---@param old_path string
                    ---@param new_path string
                    on_rename = function(old_path, new_path)
                        require("snacks").rename.on_rename_file(old_path, new_path)
                    end,
                },
                integrations = {
                    icon = "nvim_web_devicons",
                    window_picker = function()
                        return require("snacks").picker.util.pick_win({
                            filter = function(_, buf)
                                local filetype = vim.bo[buf].filetype
                                return filetype ~= "fyler_finder" and not filetype:find("^snacks")
                            end,
                        })
                    end,
                },
                mappings = {
                    n = {
                        ["<C-CR>"] = {
                            action = open_directory_in_oil,
                            desc = "Open directory in Oil float",
                        },
                        ["]g"] = {
                            action = next_changed_git_file,
                            desc = "Go to next changed Git file",
                        },
                        ["[g"] = {
                            action = previous_changed_git_file,
                            desc = "Go to previous changed Git file",
                        },
                        ["]c"] = {
                            action = next_visible_changed_git_file,
                            desc = "Go to next visible changed Git file",
                        },
                        ["[c"] = {
                            action = previous_visible_changed_git_file,
                            desc = "Go to previous visible changed Git file",
                        },
                        [","] = {
                            action = "visit",
                            args = { parent = true },
                            desc = "Go to parent directory",
                        },
                    },
                },
                ui = {
                    hidden_items = {
                        switches = {},
                    },
                    indent_guides = true,
                },
                win_opts = {
                    winfixheight = false,
                },
            })

            local group = vim.api.nvim_create_augroup("FylerFollowWorkingDirectory", { clear = true })
            vim.api.nvim_create_autocmd("DirChanged", {
                group = group,
                callback = function(_)
                    local instance = require("fyler.finder").instance_get_or_nil()
                    if not instance then
                        return
                    end

                    local cwd = vim.fn.getcwd()
                    if vim.fs.normalize(instance.state.pseudo_root_path) ~= vim.fs.normalize(cwd) then
                        instance:visit({ path = cwd })
                    end
                end,
                desc = "Follow Neovim working directory in Fyler",
            })
        end,
    },
}
