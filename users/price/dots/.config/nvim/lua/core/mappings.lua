local M = {}

---Stolen with ❤️ from https://github.com/tj-moody/.dotfiles/blob/c2afec06b68cd0413c20d332672907c11f0a9c47/nvim/lua/mappings.lua#L171C1-L171C1
---Adapted from https://vi.stackexchange.com/a/12870
---Traverse to next block with matching indent, crossing whitespace or different indent
---@param direction integer 1 for forwards, -1 for backwards
---@param equal boolean true for same indent, false for strictly less indent
---@return function handler Callback for keymap
local function indent_traverse(direction, equal)
    return function()
        local current_line, column = unpack(vim.api.nvim_win_get_cursor(0))
        local current_indent = vim.fn.indent(current_line)
        local match_line = current_line
        local buf_length = vim.api.nvim_buf_line_count(0)

        local function is_whitespace(lnum)
            local line_str = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
            return line_str:match("^%s*$") ~= nil
        end

        local function indent_matches(lnum)
            if equal then
                return vim.fn.indent(lnum) == current_indent
            else
                return vim.fn.indent(lnum) < current_indent
            end
        end

        -- We're trying to find the next valid location that matches the indentation to traverse to
        -- that is not in the current paragraph -- thus we're checking if we've crossed a gap of
        -- whitespace to a line with a matching indentation level
        local crossed_whitespace_gap = false

        while true do
            match_line = match_line + direction

            if match_line < 1 or match_line > buf_length then
                return
            end

            if is_whitespace(match_line) or not indent_matches(match_line) then
                crossed_whitespace_gap = true
            elseif crossed_whitespace_gap then
                vim.fn.cursor({ match_line, column + 1 })
                return
            end
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
        if vim.snippet then
            vim.snippet.stop()
        end
    end, { silent = true, desc = "Remove Highlights" })

    -- Set current focused file or terminal as cwd
    vim.keymap.set("n", "<leader>cd", function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].buftype == "terminal" then
            local termcwd = vim.b[buf].termcwd
            vim.cmd.cd(termcwd)
        else
            vim.cmd.cd("%:p:h")
        end
    end, { silent = true, desc = "Change CWD to Current Buffer's Directory" })

    vim.keymap.set("n", "<leader>cf", function()
        vim.g.term_follow_cwd = not vim.g.term_follow_cwd
        local state = vim.g.term_follow_cwd and "Enabled" or "Disasbled"
        vim.notify(("%s auto-following of Terminal CWD"):format(state))
    end, {
        silent = true,
        desc = "Toggle following of Terminal CWDs",
    })

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

    vim.keymap.set("n", "<leader>cc", function()
        local buf = vim.api.nvim_get_current_buf()
        ---@type string | nil
        local bufpath
        if vim.bo[buf].buftype == "terminal" then
            bufpath = vim.uv.fs_realpath(vim.b[buf].termcwd)
        else
            bufpath = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(buf))
        end

        if not bufpath then
            vim.notify("Unable to copy current buffer's path!", vim.log.levels.WARN)
            return
        end

        vim.fn.setreg("+", bufpath)
        vim.notify(("Copied current buffer path to clipboard (%s)"):format(bufpath))
    end, {
        silent = true,
        desc = "Copy current buffer's path to clipboard",
    })

    -- Terminal mappings
    vim.keymap.set("t", [[<C-\>]], [[<C-\><C-n>]], { silent = true })

    -- Alternative bindings for increment & decrement
    vim.keymap.set("n", "+", "<C-a>", { silent = true, remap = true, desc = "Increment" })
    vim.keymap.set("n", "-", "<C-x>", { silent = true, remap = true, desc = "Decrement" })

    -- Buffer bindings
    vim.keymap.set("n", "<A-a>", ":bprevious<CR>", { silent = true, desc = "Go to Previous Buffer" })
    vim.keymap.set("n", "<A-s>", ":bnext<CR>", { silent = true, desc = "Go to Next Buffer" })
    vim.keymap.set("n", "<A-d>", ":buffer#<CR>", { silent = true, desc = "Go to last buffer" })

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
        vim.diagnostic.enable(true, { buf = vim.api.nvim_get_current_buf() })
        require("plugin.wrapdiag"):toggle_current_line()
    end, {
        silent = true,
        desc = "LSP: Toggle Wrap Diagnostics",
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
    -- Create a new tab, I don't use tagstacks much if ever
    vim.keymap.set("n", "<C-T>", "<cmd>tabnew<CR>", { noremap = true, silent = true })

    -- Search within selection
    vim.keymap.set("x", "z/", "<C-\\><C-n>`</\\%V", { desc = "Search forward within visual selection" })
    vim.keymap.set("x", "z?", "<C-\\><C-n>`>?\\%V", { desc = "Search backward within visual selection" })

    -- Toggle ("set") option binds

    --- Display a message showing the new value of an option
    ---@param opt_name string The option name, e.g. `wrap`
    ---@param new_value any The new value of the option
    local function msg_show_opt(opt_name, new_value)
        local msg = ("`%s` set to `%s`"):format(opt_name, vim.inspect(new_value))
        vim.notify(msg, vim.log.levels.INFO, {
            title = "Option Set",
        })
    end

    vim.keymap.set("n", "<leader>s", "", {
        desc = "> Toggle Option",
    })
    vim.keymap.set("n", "<leader>sw", function()
        local new_wrap_value = not vim.wo.wrap
        vim.wo.wrap = not vim.wo.wrap
        msg_show_opt("wrap", new_wrap_value)
    end, {
        desc = "Toggle: Wrap",
        noremap = true,
        silent = true,
    })

    -- Clear terminal scrollback
    vim.keymap.set("t", "<C-l>", function()
        vim.fn.chansend(vim.b.terminal_job_id, vim.api.nvim_replace_termcodes("<C-l>", true, true, true))
        local sb = vim.bo.scrollback
        vim.bo.scrollback = 1
        vim.bo.scrollback = sb
    end, { desc = "Clear terminal scrollback" })

    --- Navigating across folds

    ---Jump to the next or previous fold without visible cursor flicker.
    ---@param motion string Vim motion command
    local function jump_to_fold(motion)
        local view = vim.fn.winsaveview()
        vim.cmd("silent! normal! " .. motion)
        local target = vim.fn.line(".")
        vim.fn.winrestview(view)

        if target ~= view.lnum then
            vim.api.nvim_win_set_cursor(0, { target, 0 })
        end
    end

    vim.keymap.set("n", "<C-S-j>", function()
        jump_to_fold("zj")
    end, { desc = "Go to the start of the next fold" })
    vim.keymap.set("n", "<C-S-k>", function()
        jump_to_fold("zk[z")
    end, { desc = "Go to the start of the previous fold" })
end

return M
