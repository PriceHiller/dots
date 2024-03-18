return {
    {
        "mhartington/formatter.nvim",
        keys = {
            {
                "<leader>lf",
                function()
                    local active_clients = vim.iter(
                        vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" })
                    )
                        :filter(function(lsp_client)
                            -- Exclude some language server formatters.
                            --
                            -- I chose not to override the `textDocument/formatting` handler because
                            -- it felt kinda hacky and some language servers don't play nice with
                            -- changing their handlers. Figured this was easier.
                            if lsp_client.config and lsp_client.config.name then
                                return not vim.list_contains({
                                    "lua_ls",
                                }, lsp_client.config.name)
                            end
                            return true
                        end)
                    if #active_clients > 0 then
                        vim.lsp.buf.format({ async = true })
                    else
                        vim.cmd.Format()
                    end
                end,
                -- I know this is a lie below, but I'm used to the key being LSP bound, so fuck it
                desc = "LSP: Format",
                mode = { "v", "n" },
            },
        },
        opts = function()
            local filetypes = require("formatter.filetypes")
            return {
                logging = true,
                log_level = vim.log.levels.WARN,
                filetype = {
                    markdown = filetypes.markdown.prettierd,
                    css = filetypes.css.prettierd,
                    lua = filetypes.lua.stylua,
                    sql = function()
                        return {
                            exe = "sql-formatter",
                            args = {
                                "-l",
                                "postgresql",
                                "--fix",
                            },
                        }
                    end,
                    zsh = function()
                        return {
                            exe = "shfmt",
                            args = {
                                "-",
                            },
                            stdin = true,
                        }
                    end,
                    asm = function()
                        return {
                            exe = "asmfmt",
                            stdin = true,
                        }
                    end,
                    typst = function()
                        return {
                            exe = "typstfmt",
                            stdin = true,
                        }
                    end,
                },
            }
        end,
    },
}
