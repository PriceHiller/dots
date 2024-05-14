local M = {}
M.setup = function()
    -- If invoked as a preview callback, performs 'inccommand' preview by
    -- highlighting trailing whitespace in the current buffer.
    local function trim_space_preview(opts, preview_ns, preview_buf)
        vim.cmd("highlight clear Whitespace")
        local line1 = opts.line1
        local line2 = opts.line2
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
        local preview_buf_line = 0

        for i, line in ipairs(lines) do
            local start_idx, end_idx = string.find(line, "%s+$")

            if start_idx and end_idx then
                -- Highlight the match
                vim.api.nvim_buf_add_highlight(buf, preview_ns, "Substitute", line1 + i - 2, start_idx - 1, end_idx)

                -- Add lines and set highlights in the preview buffer
                -- if inccommand=split
                if preview_buf then
                    local prefix = string.format("|%d| ", line1 + i - 1)

                    vim.api.nvim_buf_set_lines(
                        preview_buf,
                        preview_buf_line,
                        preview_buf_line,
                        false,
                        { prefix .. line }
                    )
                    vim.api.nvim_buf_add_highlight(
                        preview_buf,
                        preview_ns,
                        "Substitute",
                        preview_buf_line,
                        #prefix + start_idx - 1,
                        #prefix + end_idx
                    )
                    preview_buf_line = preview_buf_line + 1
                end
            end
        end

        -- Return the value of the preview type
        return 2
    end

    -- Trims all trailing whitespace in the current buffer.
    local function trim_space(opts)
        local line1 = opts.line1
        local line2 = opts.line2
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)

        local new_lines = {}
        for i, line in ipairs(lines) do
            new_lines[i] = string.gsub(line, "%s+$", "")
        end
        vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, false, new_lines)
    end

    -- Create the user command
    vim.api.nvim_create_user_command(
        "TrimTrailingWhitespace",
        trim_space,
        { nargs = "?", range = "%", addr = "lines", preview = trim_space_preview }
    )

    vim.api.nvim_create_user_command("DiffSaved", function()
        -- Thanks to sindrets: https://github.com/sindrets/dotfiles/blob/1990282dba25aaf49897f0fc70ebb50f424fc9c4/.config/nvim/lua/user/lib.lua#L175
        -- Minor alterations by me
        local buf_ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
        local buf_name = vim.api.nvim_buf_get_name(0)
        vim.cmd("tab split | diffthis")
        vim.cmd("aboveleft vnew | r # | normal! 1Gdd")
        vim.cmd.diffthis()
        local opts = {
            buftype = "nowrite",
            bufhidden = "wipe",
            swapfile = false,
            readonly = true,
            winbar = vim.opt.winbar:get(),
        }
        for option, value in pairs(opts) do
            vim.api.nvim_set_option_value(option, value, { scope = "local" })
        end
        if buf_name then
            pcall(vim.api.nvim_buf_set_name, 0, (vim.fn.fnamemodify(buf_name, ":t") or buf_name) .. " [OLD]")
        end
        if buf_ft then
            vim.opt_local.filetype = buf_ft
        end
        vim.cmd.wincmd("l")
    end, {})

    vim.api.nvim_create_user_command("SudoWrite", function(opts)
        opts.args = vim.trim(opts.args)
        local cmd = ":silent! w! !sudo tee " .. (#opts.args > 0 and opts.args or "%") .. " >/dev/null "
        vim.cmd(cmd)
        vim.cmd.edit({ bang = true, mods = { silent = true, confirm = false } })
        vim.bo.readonly = false
    end, {
        nargs = "*",
        desc = "Sudo Write",
    })

    vim.api.nvim_create_user_command("Tmp", function(opts)
        local fname = vim.trim(opts.args)
        local tmp_dir = vim.fn.fnamemodify(vim.fn.tempname(), ":p:h")
        vim.cmd.cd(tmp_dir)
        if fname ~= "" then
            vim.cmd.edit({ args = { fname }, bang = true })
            vim.cmd.write({ bang = true })
            vim.cmd.edit({ args = { fname }, bang = true })
        else
            pcall(vim.cmd.edit, { args = { tmp_dir } })
        end
    end, {
        nargs = "*",
        desc = "Create tempfile and cd to its directory",
    })

    local config_home = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"
    local z_lua_path = config_home .. "/zsh/config/plugins/z.lua/z.lua"
    local cached_z_listing = {}
    vim.api.nvim_create_user_command("Z", function(opts)
        cached_z_listing = {}
        local cmd = { "lua", z_lua_path, "-e", opts.args }
        local cmd_out = vim.system(cmd, { text = true, env = { _ZL_MATCH_MODE = "1", PWD = tostring(vim.uv.cwd()) } })
            :wait()
        if cmd_out.code > 0 then
            vim.notify(
                "Failed with code `" .. cmd_out.code .. "`\nSTDERR: " .. (cmd_out.stderr or ""),
                vim.log.levels.WARN,
                {
                    title = "z.lua",
                    ---@param win integer The window handle
                    on_open = function(win)
                        vim.api.nvim_set_option_value("filetype", "markdown", { buf = vim.api.nvim_win_get_buf(win) })
                    end,
                }
            )
        elseif cmd_out.stdout == "" then
            vim.notify("Did not receive a match from `z.lua`!", vim.log.levels.WARN, {
                title = "z.lua",
                ---@param win integer The window handle
                on_open = function(win)
                    vim.api.nvim_set_option_value("filetype", "markdown", { buf = vim.api.nvim_win_get_buf(win) })
                end,
            })
        else
            local stripped_stdout = cmd_out.stdout:gsub("\n$", "")
            vim.cmd("silent! cd " .. stripped_stdout)
            vim.notify("Chdir to `" .. stripped_stdout .. "`", vim.log.levels.INFO, {
                title = "z.lua",
                ---@param win integer The window handle
                on_open = function(win)
                    vim.api.nvim_set_option_value("filetype", "markdown", { buf = vim.api.nvim_win_get_buf(win) })
                end,
            })
        end
    end, {
        nargs = "+",
        complete = function(_, _, _)
            local cmd = { "lua", z_lua_path, "--complete" }
            local cmd_out
            if #cached_z_listing == 0 then
                cmd_out = vim.system(cmd, { text = true }):wait()
                if cmd_out.code == 0 and cmd_out.stdout then
                    cached_z_listing = vim.split(cmd_out.stdout, "\n")
                end
            end
            return cached_z_listing
        end,
        desc = "Invoke `z.lua`",
    })

    vim.api.nvim_create_autocmd("DirChanged", {
        callback = function(args)
            vim.system({ "lua", z_lua_path, "--add", args.file }, { text = true }, function(out)
                if out.code ~= 0 then
                    vim.notify(
                        "Failed to regiser directory with `z.lua`!\n====STDERR====\n"
                            .. out.stderr
                            .. "\n====STDOUT====\n"
                            .. out.stdout,
                        vim.log.levels.WARN,
                        {
                            title = "z.lua",
                            on_open = function(win)
                                vim.api.nvim_set_option_value(
                                    "filetype",
                                    "markdown",
                                    { buf = vim.api.nvim_win_get_buf(win) }
                                )
                            end,
                        }
                    )
                end
            end)
        end,
    })
end

return M
