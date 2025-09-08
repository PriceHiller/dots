---@type boolean
vim.g.term_follow_cwd = true

--- NOTE: Handle OSC 7 dir changed requests and sets the current terminal directory into a buffer
--- variable for the terminal.
---
--- NOTE: Requires a hook in the shell config to emit the directory on each dir change via OSC
--- escape codes.
vim.api.nvim_create_autocmd({ "TermRequest" }, {
    desc = "Handle OSC 7 dir change requests and sets the terminal CWD in a buffer variable",
    callback = function(ev)
        local bufnr = ev.buf
        if not vim.b[bufnr] then
            return
        end

        if string.sub(vim.v.termrequest, 1, 4) == "\x1b]7;" then
            local dir = vim.v.termrequest:gsub("\x1b]7;file://[^/]*", "")
            dir = vim.fn.fnameescape(dir)
            vim.b[bufnr].termcwd = dir
            if vim.g.term_follow_cwd then
                vim.cmd.cd(dir)
            end
        end
    end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    desc = "Set newly created terminal CWD in a buffer variable",
    callback = function(ev)
        local bufnr = ev.buf
        if not vim.b[bufnr] then
            return
        end

        vim.b[bufnr].termcwd = vim.fn.getcwd()
    end,
})
