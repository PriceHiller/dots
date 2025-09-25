local bufnr = vim.api.nvim_get_current_buf()

vim.api.nvim_create_autocmd("BufUnload", {
    desc = "Copy `gitcommit` content to clipboard on close",
    once = true,
    buffer = bufnr,
    callback = function(args)
        local buf_lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)

        local lines = {}
        for _, buf_line in ipairs(buf_lines) do
            -- Only get lines that aren't comment lines
            if not buf_line:match("%s*#.*") then
                -- Remove trailing whitespace on lines
                buf_line = buf_line:gsub("%s*$", "")
                table.insert(lines, buf_line)
            end
        end

        -- Remove whitespace surrounding the entirety of the git commit content
        local content = vim.trim(table.concat(lines, "\n"))
        -- Finally, copy that bad boy to the clipboard
        vim.fn.setreg("+", content)

        return true
    end,
})
