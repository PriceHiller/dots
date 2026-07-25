vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    desc = "Lazily enable language servers when opening a file",
    once = true,
    callback = function()
        for _, dir in ipairs({
            "lsp",
            "after/lsp",
        }) do
            local lspcfg_dir = ("%s/%s"):format(vim.fn.stdpath("config"), dir)
            vim.uv.fs_scandir(lspcfg_dir, function(_, fd)
                if not fd then
                    return
                end

                for lspcfg_file in
                    function()
                        return vim.uv.fs_scandir_next(fd)
                    end
                do
                    local lsp_name = lspcfg_file:gsub("%.lua", "")
                    vim.schedule(function()
                        local success, err_msg = pcall(vim.lsp.enable, lsp_name)
                        if not success then
                            vim.notify(
                                table.concat({

                                    "==========",
                                    ("Failed to enable language server: '%s'"):format(lsp_name),
                                    "----------",
                                    "",
                                    err_msg,
                                    "----------",
                                    "",
                                }, "\n"),
                                vim.log.levels.WARN
                            )
                        end
                    end)
                end
            end)
        end

        return true
    end,
})
