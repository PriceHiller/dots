return {
    -- Thanks https://github.com/withastro/language-tools/issues/958#issuecomment-2755897254
    on_attach = function(client, _)
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("Astro-OnDidChange-External-Faile", { clear = true }),
            desc = "Update Astro's language server with change events for non-astro files",
            pattern = {
                "*.js",
                "*.ts",
                "*.jsx",
                "*.tsx",
                "*.json",
                "*.scss",
                "*.css",
                "*.mdx",
                "*.md",
            },
            callback = function(ctx)
                client.notify("workspace/didChangeWatchedFiles", {
                    changes = {
                        {
                            uri = ctx.match,
                            -- 1 = Created, 2 = Changed, 3 = Deleted
                            type = 2,
                        },
                    },
                })
            end,
        })
    end,
}
