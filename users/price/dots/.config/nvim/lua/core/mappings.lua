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

    -- Spell Checking
    vim.keymap.set("n", "<leader>ss", function()
        vim.opt.spell = not vim.opt.spell:get()
    end, { silent = true, desc = "Toggle Spell" })

    -- Toggling wrap
    vim.keymap.set("n", "<leader>sw", function()
        vim.opt.wrap = not vim.opt.wrap:get()
    end, { silent = true, desc = "Toggle Wrap" })

    -- Set current focused file as cwd
    vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>", { silent = true, desc = "Change CWD to Current File" })

    -- Toggle relativenumber
    vim.keymap.set("n", "<leader>sr", function()
        vim.opt.relativenumber = not vim.opt.relativenumber:get()
    end, { silent = true, desc = "Toggle Relativenumber" })

    -- Terminal mappings
    vim.keymap.set("t", [[<C-\>]], [[<C-\><C-n>]], { silent = true })

    -- Alternative bindings for increment & decrement
    vim.keymap.set("n", "+", "<C-a>", { silent = true, remap = true, desc = "Increment" })
    vim.keymap.set("n", "-", "<C-x>", { silent = true, remap = true, desc = "Decrement" })

    -- Tabclose binding
    vim.keymap.set("n", "<C-w>t", "<cmd>tabclose<CR>", { silent = true, desc = "Close Tab" })

    -- Buffer bindings
    vim.keymap.set("n", "<A-a>", ":bprevious<CR>", { silent = true, desc = "Go to Previous Buffer" })
    vim.keymap.set("n", "<A-s>", ":bnext<CR>", { silent = true, desc = "Go to Next Buffer" })

    -- Binding to insert literal tab
    vim.keymap.set("i", "<C-Tab>", function()
        if vim.opt_local.expandtab:get() then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-V><TAB>", true, false, true), "m", true)
        else
            local spaces = string.rep(" ", vim.opt_local.shiftwidth:get() or 4)
            vim.api.nvim_feedkeys(spaces, "m", false)
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
    vim.keymap.set("i", "<C-S-CR>", "<C-o>O", { silent = true, desc = "Insert: New Line" })

    -- Copy first leading word of line onto newline and insert (autolist functionality basically)
    vim.keymap.set("i", "<C-CR>", function()
        local line = vim.api.nvim_get_current_line()
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
        local new_line = indent .. word .. trailing

        local win = vim.api.nvim_get_current_win()
        local row, _ = table.unpack(vim.api.nvim_win_get_cursor(win))
        vim.fn.append(row, new_line)
        vim.api.nvim_win_set_cursor(win, { row + 1, vim.fn.strdisplaywidth(new_line) })
    end, { silent = true, desc = "Insert: Autolist" })

    -- Insert an Em Dash in insert mode
    vim.keymap.set("i", "<A-->", "—", { silent = true, desc = "Insert: Em Dash" })

    -- Keymap to toggle folds easier
    vim.keymap.set("n", "<Tab>", "za", { silent = true, desc = "Toggle Fold" })

    -- Alias <leader>/ to toggle comments
    vim.keymap.set("n", "<leader>/", "gcc", { silent = true, remap = true, desc = "Comment: Toggle Line" })
    vim.keymap.set("v", "<leader>/", "gc", { silent = true, remap = true, desc = "Comment: Toggle Selection" })

    -- Bring up messages via keybind
    vim.keymap.set("n", ";m", "<cmd>message<CR>", { silent = true, noremap = true, desc = "View Messages" })

    -- Delete whole world back in insert & cmd mode
    vim.keymap.set({ "i", "c" }, "<C-BS>", "<C-W>")

    -- Move cursor using C-(h,j,k,l) in insert mode
    --
    -- I know that these are default bindings deep in Vim and technically break `:h digraphs`
    -- bindings, but I so rarely need actual digraphs that I reall don't care. If it's that big a
    -- problem I'll come up with something else 🤷
    vim.keymap.set({ "i" }, "<C-k>", "<Up>")
    vim.keymap.set({ "i" }, "<C-j>", "<Down>")
    vim.keymap.set({ "i" }, "<C-l>", "<Right>")
    vim.keymap.set({ "i" }, "<C-h>", "<Left>")
    vim.keymap.set({ "i" }, "<C-;>", "<C-k>")

    -- Toggle lsp diagnostic appearance
    vim.keymap.set("n", "<leader>lt", function()
        ---@diagnostic disable-next-line: undefined-field
        local diag_config = vim.diagnostic.config()
        if not diag_config then
            return
        end
        if diag_config.virtual_lines == diag_config.virtual_text  then
            diag_config.virtual_text = not diag_config.virtual_text
        end
        vim.diagnostic.config({
            virtual_lines = not diag_config.virtual_lines,
            virtual_text =  not diag_config.virtual_text
        })
    end, {
        silent = true,
        desc = "LSP: Toggle Virtual Lines",
    })
end

return M
