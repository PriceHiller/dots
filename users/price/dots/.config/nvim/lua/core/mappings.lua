local M = {}

---Stolen with ❤️ from https://github.com/tj-moody/.dotfiles/blob/c2afec06b68cd0413c20d332672907c11f0a9c47/nvim/lua/mappings.lua#L171C1-L171C1
---Adapted from https://vi.stackexchange.com/a/12870
---Traverse to indent >= or > current indent
---@param direction integer 1 - forwards | -1 - backwards
---@param equal boolean include lines equal to current indent in search?
local function indent_traverse(direction, equal) -- {{{
    return function()
        -- Get the current cursor position
        local current_line, column = unpack(vim.api.nvim_win_get_cursor(0))
        local match_line = current_line
        local match_indent = false
        local match = false

        local buf_length = vim.api.nvim_buf_line_count(0)

        -- Look for a line of appropriate indent
        -- level without going out of the buffer
        while (not match) and (match_line ~= buf_length) and (match_line ~= 1) do
            match_line = match_line + direction
            local match_line_str = vim.api.nvim_buf_get_lines(0, match_line - 1, match_line, false)[1]
            -- local match_line_is_whitespace = match_line_str and match_line_str:match('^%s*$')
            local match_line_is_whitespace = match_line_str:match("^%s*$")

            if equal then
                match_indent = vim.fn.indent(match_line) <= vim.fn.indent(current_line)
            else
                match_indent = vim.fn.indent(match_line) < vim.fn.indent(current_line)
            end
            match = match_indent and not match_line_is_whitespace
        end

        -- If a line is found go to line
        if match or match_line == buf_length then
            vim.fn.cursor({ match_line, column + 1 })
        end
    end
end

M.setup = function()
    -- set mapleader to space
    vim.g.mapleader = " "
    vim.g.maplocalleader = ";"

    -- Get rid of highlight after search
    vim.keymap.set("n", "<esc>", function()
        vim.cmd.noh()
    end, { silent = true, desc = "Remove Highlighted Searches" })

    -- Set current focused file as cwd
    vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>", { silent = true, desc = "Change CWD to Current File" })
    vim.keymap.set("n", "<leader>cg", function()
        local cur_buf = vim.api.nvim_get_current_buf()
        local cur_file = vim.api.nvim_buf_get_name(cur_buf)
        local cur_file_dir = vim.fn.fnamemodify(cur_file, ":p:h")
        local git_status = vim.system({ "git", "status" }, { cwd = cur_file_dir }):wait()
        if git_status.code ~= 0 then
            vim.notify("File is not in a git directory!", vim.log.levels.ERROR)
            return
        end

        local git_dir = vim.fs.root(cur_file_dir, ".git")
        if not git_dir then
            error(
                "Failed to locate the root git directory despite git status implying current file is in a git repository!"
            )
            return
        end

        vim.cmd.cd(git_dir)
    end, { silent = true, desc = "Change CWD to Root of Git Directory For Current File" })

    -- Terminal mappings
    vim.keymap.set("t", [[<C-\>]], [[<C-\><C-n>]], { silent = true })

    -- Alternative bindings for increment & decrement
    vim.keymap.set("n", "+", "<C-a>", { silent = true, remap = true, desc = "Increment" })
    vim.keymap.set("n", "-", "<C-x>", { silent = true, remap = true, desc = "Decrement" })

    -- Buffer bindings
    vim.keymap.set("n", "<A-a>", ":bprevious<CR>", { silent = true, desc = "Go to Previous Buffer" })
    vim.keymap.set("n", "<A-s>", ":bnext<CR>", { silent = true, desc = "Go to Next Buffer" })

    -- Binding to insert literal tab
    vim.keymap.set("i", "<C-Tab>", function()
        if vim.bo.expandtab then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-V><TAB>", true, false, true), "m", true)
        else
            local spaces = string.rep(" ", math.max(vim.o.shiftwidth, 4))
            vim.api.nvim_put({ spaces }, "c", false, true)
        end
    end, { silent = true, desc = "Insert Literal Tab" })

    -- Binding to keep S-Space in terminals from not sending <Space>
    vim.keymap.set("t", "<S-Space>", "<Space>", { silent = true, desc = "Terminal: Hack S-Space to Space" })

    vim.keymap.set(
        { "n", "v" },
        "<C-j>",
        indent_traverse(1, true),
        { silent = true, desc = "Move: To next equal indent" }
    )
    vim.keymap.set(
        { "n", "v" },
        "<C-k>",
        indent_traverse(-1, true),
        { silent = true, desc = "Move: To previous equal indent" }
    )

    -- Binding to go to older and newer quickfix list
    vim.keymap.set("n", "]q", "<cmd>cnewer<CR>", { silent = true, desc = "Quickfix: Newer" })
    vim.keymap.set("n", "]q", "<cmd>colder<CR>", { silent = true, desc = "Quickfix: Older" })

    -- Binding to allow ctrl - < dedent
    vim.keymap.set("i", "<C-<>", "<C-d>", { silent = true, desc = "Insert: Dedent" })
    -- Binding to allow ctrl - > indent
    vim.keymap.set("i", "<C->>", "<C-t>", { silent = true, desc = "Insert: Indent" })

    -- Create newline from anywhere in current line without modifying current line
    vim.keymap.set("i", "<S-CR>", "<C-o>o", { silent = true, desc = "Insert: New Line" })

    -- Copy first leading word of line onto newline and insert (autolist functionality basically)
    vim.keymap.set({ "i", "n" }, "<C-CR>", function()
        local line = vim.api.nvim_get_current_line()
        ---@type string, string, string
        local indent, word, trailing = line:match("^(%s*)(%S*)(%s*)")
        if #word == 0 then
            return
        end

        local num, num_trail = word:match("^(%d*)(%D*)")
        -- TODO: If we add a new list item that uses a number in the middle of a bunch of list
        -- numbers, we should ideally increment all the next number nodes. Might require integrating
        -- treesitter or, alternatively, just look for all starting list number nodes at the same
        -- indent level and increment them.
        if #num > 0 then
            num = tonumber(num) + 1
            word = tostring(num) .. num_trail
        end
        if trailing:sub(-1) ~= " " then
            trailing = trailing .. " "
        end
        local new_line = indent .. word .. trailing

        local win = vim.api.nvim_get_current_win()
        local cursor = vim.api.nvim_win_get_cursor(win)
        vim.fn.append(cursor[1], new_line)
        vim.cmd.startinsert()
        vim.api.nvim_win_set_cursor(win, { cursor[1] + 1, vim.fn.strdisplaywidth(new_line) + 1 })
    end, { silent = true, desc = "Insert: Autolist" })

    -- Insert an Em Dash in insert mode
    vim.keymap.set("i", "<A-->", "—", { silent = true, desc = "Insert: Em Dash" })

    -- Keymap to toggle folds easier
    --
    -- This is done to preseve the `jump` map, see `:h CTRL-I`, has to come before rebinding `<TAB>`
    -- See https://github.com/neovim/neovim/issues/14090#issuecomment-1113090354
    vim.keymap.set("n", "<C-i>", "<C-I>")
    vim.keymap.set("n", "<Tab>", "za", { silent = true, desc = "Toggle Fold" })

    -- Alias <leader>/ to toggle comments
    vim.keymap.set("n", "<leader>/", "gcc", { silent = true, remap = true, desc = "Comment: Toggle Line" })
    vim.keymap.set("v", "<leader>/", "gc", { silent = true, remap = true, desc = "Comment: Toggle Selection" })

    -- Bring up messages via keybind
    vim.keymap.set("n", ";m", "<cmd>message<CR>", { silent = true, noremap = true, desc = "View Messages" })

    -- Delete whole world back in insert & cmd mode
    vim.keymap.set({ "i", "c" }, "<C-BS>", "<C-W>")

    -- Toggle lsp diagnostic appearance
    vim.keymap.set("n", "<leader>lt", function()
        ---@diagnostic disable-next-line: undefined-field
        local diag_config = vim.diagnostic.config()
        if not diag_config then
            return
        end
        if diag_config.virtual_lines == diag_config.virtual_text then
            diag_config.virtual_text = not diag_config.virtual_text
        end
        vim.diagnostic.enable(true, { buf = vim.api.nvim_get_current_buf() })
        vim.diagnostic.config({
            virtual_lines = not diag_config.virtual_lines,
            virtual_text = not diag_config.virtual_text,
        })
    end, {
        silent = true,
        desc = "LSP: Toggle Virtual Lines",
    })

    -- Credit to https://www.reddit.com/r/neovim/comments/1k3lhac/tiny_quality_of_life_rebind_make_j_and_k/
    -- Adds a mark to the jumplist on counted j and k motions and makes j and k by default use
    -- screen lines instead of real lines (gk, gj)
    vim.keymap.set("n", "k", function()
        return vim.v.count > 0 and "m'" .. vim.v.count .. "k" or "gk"
    end, { expr = true })

    vim.keymap.set("n", "j", function()
        return vim.v.count > 0 and "m'" .. vim.v.count .. "j" or "gj"
    end, { expr = true })

    vim.keymap.set("n", "<localleader>fr", function()
        local buf = vim.api.nvim_get_current_buf()
        vim.notify("Opening current file via xdg-open")
        vim.system({ "xdg-open", vim.api.nvim_buf_get_name(buf) }, { detach = true })
    end, {
        desc = "File: XDG Open",
    })

    -- Tab Keybindings
    vim.keymap.set({ "", "!", "v" }, "<C-S-CR>", function()
        local cursor_pos = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
        local success, _ = pcall(vim.cmd.tabedit, "%")
        if success then
            pcall(vim.api.nvim_win_set_cursor, vim.api.nvim_get_current_win(), cursor_pos)
        else
            vim.cmd.tabedit()
        end
    end, { noremap = true, silent = true })
    -- Next/prev tabs
    vim.keymap.set({ "", "!", "v", "t" }, "<C-:>", "<cmd>tabnext<CR>", { noremap = true, silent = true })
    vim.keymap.set({ "", "!", "v", "t" }, '<C-">', "<cmd>tabprevious<CR>", { noremap = true, silent = true })
    -- Close tab
    vim.keymap.set({ "", "!", "v", "t" }, "<C-|>", "<cmd>tabclose<CR>", { noremap = true, silent = true })

    -- Search within selection
    vim.keymap.set("x", "z/", "<C-\\><C-n>`</\\%V", { desc = "Search forward within visual selection" })
    vim.keymap.set("x", "z?", "<C-\\><C-n>`>?\\%V", { desc = "Search backward within visual selection" })
end

return M
