return {
    {
        "nvimtools/none-ls.nvim",
        lazy = false,
        config = function()
            local null_ls = require("null-ls")
            local h = require("null-ls.helpers")
            local methods = require("null-ls.methods")
            local d2_validate = h.make_builtin({
                name = "d2",
                meta = {
                    url = "https://d2lang.com/",
                    description = "D2 Validate",
                },
                method = methods.internal.DIAGNOSTICS_ON_SAVE,
                filetypes = { "d2" },
                generator_opts = {
                    command = "d2",
                    args = {
                        "$FILENAME",
                        "-",
                    },
                    format = "line",
                    ignore_stdout = true,
                    from_stderr = true,
                    to_temp_file = true,
                    on_output = h.diagnostics.from_pattern(
                        [[(%w+):.*(%d+):(%d+): (.+)]],
                        { "severity", "row", "col", "message" },
                        {
                            severities = {
                                err = vim.diagnostic.severity.ERROR,
                            },
                        }
                    ),
                },
                factory = h.generator_factory,
            })

            local ts_query_fmt = h.make_builtin({
                name = "ts-query-fmt",
                meta = {
                    url = "https://github.com/nvim-treesitter/nvim-treesitter/blob/main/CONTRIBUTING.md#formatting",
                    description = "Tree-sitter query formatter.",
                },
                method = methods.internal.FORMATTING,
                filetypes = { "query" },
                generator_opts = {
                    command = "nvim",
                    args = (function()
                        local script = vim.api.nvim_get_runtime_file("scripts/format-queries.lua", false)[1]
                        local rtp = vim.fn.fnamemodify(script, ":h:h")
                        return { "-c", "set rtp^=" .. rtp, "-l", script, "$FILENAME" }
                    end)(),
                    to_stdin = false,
                    to_temp_file = true,
                },
                factory = h.formatter_factory,
            })

            local sqlfluff_config = {
                extra_args = { "--dialect", "mysql" },
            }
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.d2_fmt,
                    d2_validate,
                    ts_query_fmt,
                    null_ls.builtins.formatting.google_java_format,
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.asmfmt,
                    null_ls.builtins.formatting.typstyle,
                    null_ls.builtins.formatting.cmake_format,
                    null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.formatting.shfmt,
                    null_ls.builtins.diagnostics.actionlint,
                    null_ls.builtins.formatting.markdownlint,
                    null_ls.builtins.diagnostics.hadolint,
                    null_ls.builtins.diagnostics.sqlfluff.with(sqlfluff_config),
                    null_ls.builtins.formatting.sqlfluff.with(sqlfluff_config),
                },
            })
        end,
    },
}
