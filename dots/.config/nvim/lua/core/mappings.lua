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
    vim.keymap.set("n", "<leader>st", function()
        vim.opt.spell = not vim.opt.spell:get()
    end, { silent = true, desc = "Toggle Spell" })

    -- Set current focused file as cwd
    vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>", { silent = true, desc = "Change CWD to Current File" })

    vim.keymap.set("n", "<leader>lh", function()
        if vim.diagnostic.is_disabled() then
            vim.diagnostic.enable()
        else
            vim.diagnostic.disable()
        end
    end, { silent = true, desc = "LSP: Toggle Diagnostics" })

    -- Toggle showing command bar
    vim.keymap.set("n", "<leader>sc", function()
        local current_cmdheight = vim.opt.cmdheight:get()
        if current_cmdheight > 0 then
            vim.opt.cmdheight = 0
        else
            vim.opt.cmdheight = 1
        end
    end, { silent = true, desc = "Toggle Cmdline" })

    -- Toggle relativenumber
    vim.keymap.set("n", "<leader>sn", function()
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
    vim.keymap.set("i", "<S-Tab>", function()
        if vim.opt_local.expandtab:get() then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-V><TAB>", true, false, true), "m", true)
        else
            local spaces = string.rep(" ", vim.opt_local.shiftwidth:get() or 4)
            vim.api.nvim_feedkeys(spaces, "m", false)
        end
    end, { silent = true, desc = "Insert Literal Tab" })

    -- Binding to keep S-Space in terminals from not sending <Space>
    vim.keymap.set("t", "<S-Space>", "<Space>", { silent = true, desc = "Terminal: Hack S-Space to Space" })

    vim.keymap.set("n", "<C-j>", indent_traverse(1, true), { silent = true, desc = "Move: To next equal indent" })
    vim.keymap.set("n", "<C-k>", indent_traverse(-1, true), { silent = true, desc = "Move: To previous equal indent" })

    -- Binding to go to older and newer quickfix list
    vim.keymap.set("n", "]q", "<cmd>cnewer<CR>", { silent = true, desc = "Quickfix: Newer" })
    vim.keymap.set("n", "]q", "<cmd>colder<CR>", { silent = true, desc = "Quickfix: Older" })
end

return M
