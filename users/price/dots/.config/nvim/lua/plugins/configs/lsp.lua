return {
    {
        "smjonas/inc-rename.nvim",
        cmd = { "IncRename" },
        keys = {
            {
                "<leader>ln",
                function()
                    return ":IncRename " .. vim.fn.expand("<cword>")
                end,
                desc = "LSP: Rename",
                expr = true,
            },
        },
        opts = {},
    },
    {
        "kosayoda/nvim-lightbulb",
        event = "LspAttach",
        opts = function()
            local text_icon = ""
            local nvim_lightbulb = require("nvim-lightbulb")
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
                callback = nvim_lightbulb.update_lightbulb,
            })
            return {
                link_highlights = false,
                sign = {
                    enabled = true,
                    text = text_icon,
                },
            }
        end,
    },
    {
        "aznhe21/actions-preview.nvim",
        opts = {
            backend = { "snacks" },
            snacks = {
                layout = { preset = "vertical" },
            },
            telescope = {
                border = {},
                layout_strategy = "vertical",
                layout_config = {
                    width = 0.8,
                    height = 0.7,
                },
            },
        },
        keys = {
            {
                "<leader>lc",
                function()
                    -- HACK: Make code actions work with `nvim-java`, tracking https://github.com/aznhe21/actions-preview.nvim/issues/50
                    if vim.bo.filetype == "java" then
                        vim.lsp.buf.code_action()
                    else
                        require("actions-preview").code_actions()
                    end
                end,
                desc = "LSP: Code Action",
                mode = { "n", "v" },
            },
        },
    },
    {
        "mrcjkb/rustaceanvim",
        lazy = false,
        config = false,
    },
    {
        "williamboman/mason.nvim",
        opts = {
            max_concurrent_installers = 12,
            registries = {
                "github:nvim-java/mason-registry",
                "github:mason-org/mason-registry",
            },
        },
        cmd = {
            "Mason",
            "MasonLog",
            "MasonUpdate",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
        },
    },
    {
        "nvim-java/nvim-java",
        ft = { "java" },
    },
    (function()
        local filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
        }
        return {
            "pmizio/typescript-tools.nvim",
            dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
            ft = filetypes,
            config = function()
                require("typescript-tools").setup({
                    filetypes = filetypes,
                    settings = {
                        tsserver_plugins = {
                            "@vue/typescript-plugin",
                        },
                    },
                })
            end,
        }
    end)(),
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        lazy = true,
        init = function()
            local lspConfigPath = require("lazy.core.config").options.root .. "/nvim-lspconfig"

            -- INFO `prepend` ensures it is loaded before the user's LSP configs, so
            -- that the user's configs override nvim-lspconfig.
            vim.opt.runtimepath:prepend(lspConfigPath)
        end,
        dependencies = {
            "actionshrimp/direnv.nvim", -- This ensures that direnv is loaded first
            "williamboman/mason.nvim",
            "Decodetalkers/csharpls-extended-lsp.nvim",
            "Hoffs/omnisharp-extended-lsp.nvim",
            "b0o/schemastore.nvim",
            {
                "nvimtools/none-ls.nvim",
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
                                "-"
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
                    local sqlfluff_config = {
                        extra_args = { "--dialect", "mysql" },
                    }
                    null_ls.setup({
                        sources = {
                            null_ls.builtins.formatting.d2_fmt,
                            d2_validate,
                            null_ls.builtins.formatting.google_java_format,
                            null_ls.builtins.formatting.stylua,
                            null_ls.builtins.formatting.asmfmt,
                            null_ls.builtins.formatting.typstyle,
                            null_ls.builtins.formatting.cmake_format,
                            null_ls.builtins.formatting.shfmt,
                            null_ls.builtins.formatting.prettierd,
                            null_ls.builtins.diagnostics.hadolint,
                            null_ls.builtins.diagnostics.sqlfluff.with(sqlfluff_config),
                            null_ls.builtins.formatting.sqlfluff.with(sqlfluff_config),
                        },
                    })
                end,
            },
        },
        keys = {
            { "<leader>l", desc = "> LSP" },
            {
                "<leader>lf",
                function()
                    vim.lsp.buf.format({
                        async = true,
                        filter = function(client)
                            return not vim.list_contains({ "lua_ls", "jdtls" }, client.name)
                        end,
                    })
                end,
                desc = "LSP: Format",
                mode = { "v", "n" },
            },
            {
                "<leader>lh",
                function()
                    local kwargs = { buf = vim.api.nvim_get_current_buf() }
                    vim.diagnostic.enable(not vim.diagnostic.is_enabled(kwargs), kwargs)
                end,
                desc = "LSP: Toggle Diagnostics in Current Buffer",
            },
            { "<leader>lR", ":LspRestart<CR>", desc = "LSP: Restart" },
            {
                "<leader>ls",
                function()
                    vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
                end,
                desc = "LSP: Diagnostic Open Float",
            },
            {
                "[l",
                function()
                    vim.diagnostic.jump({ count = -1, float = true })
                end,
                desc = "LSP: Diagnostic Previous",
            },
            {
                "]l",
                function()
                    vim.diagnostic.jump({ count = 1, float = true })
                end,
                desc = "LSP: Diagnostic Next",
            },
            {
                "<leader>ll",
                function()
                    local kwargs = { bufnr = 0 }
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(kwargs), kwargs)
                end,
                desc = "LSP: Toggle Inlay Hints",
            },
        },
    },
}
