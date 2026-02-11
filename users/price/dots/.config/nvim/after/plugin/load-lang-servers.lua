-- Enable all language servers defined in `lsp/` & `after/lsp/`
for _, dir in ipairs({
    "lsp",
    "after/lsp",
}) do
    local lspcfg_dir = ("%s/%s"):format(vim.fn.stdpath("config"), dir)
    local fd = vim.uv.fs_scandir(lspcfg_dir)
    if fd then
        for lspcfg_file in
            function()
                return vim.uv.fs_scandir_next(fd)
            end
        do
            local lsp_name = lspcfg_file:gsub(".lua\z", "")
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
        end
    end
end
