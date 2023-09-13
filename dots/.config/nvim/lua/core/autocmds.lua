local M = {}

M.setup = function()
    local augroup = vim.api.nvim_create_augroup("user-autocmds", { clear = true })
    -- NOTE: Highlight text yanked
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = augroup,
        callback = function()
            vim.highlight.on_yank()
        end,
    })

    local strip_trail_space = true
    vim.api.nvim_create_user_command("ToggleStripTrailSpace", function()
        strip_trail_space = not strip_trail_space
        local intercept_state = "`Enabled`"
        if not strip_trail_space then
            intercept_state = "`Disabled`"
        end
        vim.notify("Strip Trail Space set to " .. intercept_state, vim.log.levels.INFO, {
            title = "Strip Trail Space",
            ---@param win integer The window handle
            on_open = function(win)
                vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(win), "filetype", "markdown")
            end,
        })
    end, { desc = "Toggles intercepting BufWritePre to strip trail space" })

    -- NOTE: Remove trailing whitespace on save
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        callback = function()
            if strip_trail_space then
                vim.cmd.StripTrailSpace()
            end
        end,
    })

    -- NOTE: Disables status column elements in Terminal buffer
    vim.api.nvim_create_autocmd("TermOpen", {
        group = augroup,
        callback = function()
            vim.api.nvim_set_option_value("statuscolumn", "", { scope = "local" })
            vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local" })
            vim.api.nvim_set_option_value("number", false, { scope = "local" })
            vim.api.nvim_set_option_value("relativenumber", false, { scope = "local" })
            vim.cmd.startinsert()
        end,
    })

    -- NOTE: Removes No Name buffers, thanks
    -- https://www.reddit.com/r/neovim/comments/16b0n3a/comment/jzcbhxo/?utm_source=share&utm_medium=web2x&context=3
    vim.api.nvim_create_autocmd("BufHidden", {
        group = augroup,
        desc = "Delete [No Name] buffers",
        callback = function(event)
            if event.file == "" and vim.bo[event.buf].buftype == "" and not vim.bo[event.buf].modified then
                vim.schedule(function()
                    pcall(vim.api.nvim_buf_delete, event.buf, {})
                end)
            end
        end,
    })
    -- NOTE: Launches a different program for a given filetype instead of opening it in Neovim
    local intercept_file_open = true
    vim.api.nvim_create_user_command("InterceptToggle", function()
        intercept_file_open = not intercept_file_open
        local intercept_state = "`Enabled`"
        if not intercept_file_open then
            intercept_state = "`Disabled`"
        end
        vim.notify("Intercept file open set to " .. intercept_state, vim.log.levels.INFO, {
            title = "Intercept File Open",
            ---@param win integer The window handle
            on_open = function(win)
                vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(win), "filetype", "markdown")
            end,
        })
    end, { desc = "Toggles intercepting BufNew to open files in custom programs" })

    -- NOTE: Add "BufReadPre" to the autocmd events to also intercept files given on the command line, e.g.
    -- `nvim myfile.txt`
    vim.api.nvim_create_autocmd({ "BufNew" }, {
        group = augroup,
        callback = function(args)
            ---@type string
            local path = args.match
            ---@type integer
            local bufnr = args.buf

            ---@type string? The file extension if detected
            local extension = vim.fn.fnamemodify(path, ":e")
            ---@type string? The filename if detected
            local filename = vim.fn.fnamemodify(path, ":t")

            ---Open a given file path in a given program and remove the buffer for the file.
            ---@param buf integer The buffer handle for the opening buffer
            ---@param fpath string The file path given to the program
            ---@param fname string The file name used in notifications
            local function open_mime(buf, fpath, fname)
                vim.notify(string.format("Opening `%s` in external program", fname), vim.log.levels.INFO, {
                    title = "Open File in External Program",
                    ---@param win integer The window handle
                    on_open = function(win)
                        vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(win), "filetype", "markdown")
                    end,
                })
                vim.system({ "xdg-open", fpath }, { detach = true })
                vim.api.nvim_buf_delete(buf, { force = true })
            end

            local extension_callbacks = {
                ["pdf"] = function(buf, fpath, fname)
                    open_mime(buf, fpath, fname)
                end,
                ["png"] = function(buf, fpath, fname)
                    open_mime(buf, fpath, fname)
                end,
                ["jpg"] = "png",
                ["mp4"] = function(buf, fpath, fname)
                    open_mime(buf, fpath, fname)
                end,
                ["gif"] = "mp4",
            }

            ---Get the extension callback for a given extension. Will do a recursive lookup if an extension callback is actually
            ---of type string to get the correct extension
            ---@param ext string A file extension. Example: `png`.
            ---@return fun(bufnr: integer, path: string, filename: string?) extension_callback The extension callback to invoke, expects a buffer handle, file path, and filename.
            local function extension_lookup(ext)
                local callback = extension_callbacks[ext]
                if type(callback) == "string" then
                    callback = extension_lookup(callback)
                end
                return callback
            end

            if extension ~= nil and not extension:match("^%s*$") and intercept_file_open then
                local callback = extension_lookup(extension)
                if type(callback) == "function" then
                    callback(bufnr, path, filename)
                end
            end
        end,
    })
end

return M
