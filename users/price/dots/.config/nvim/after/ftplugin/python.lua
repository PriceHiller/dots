-- Treesitter automatic Python format strings
-- THANKS https://gist.github.com/linguini1/ee91b6d8c196cbd731d10a61447af6a3
vim.api.nvim_create_augroup("py-fstring", { clear = true })
vim.api.nvim_create_autocmd("InsertCharPre", {
    pattern = { "*.py" },
    group = "py-fstring",
    --- @return nil
    callback = function(opts)
        -- Only run if f-string escape character is typed
        if vim.v.char ~= "{" then
            return
        end

        -- Get node and return early if not in a string
        local node = vim.treesitter.get_node()

        if not node then
            return
        end
        if node:type() ~= "string" then
            node = node:parent()
        end
        if not node or node:type() ~= "string" then
            return
        end

        local row, col, _, _ = vim.treesitter.get_node_range(node)

        -- Return early if string is already a format string
        local first_char = vim.api.nvim_buf_get_text(opts.buf, row, col, row, col + 1, {})[1]
        if first_char == "f" then
            return
        end

        -- Otherwise, make the string a format string
        vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<Esc>`'la")
    end,
})

vim.keymap.set("n", "<leader>fr", function()
    vim.cmd.write()
    require("toggleterm").exec("python " .. vim.api.nvim_buf_get_name(0))
end, {
    buffer = true,
    desc = "Python: Save and Run Current Buffer",
})
