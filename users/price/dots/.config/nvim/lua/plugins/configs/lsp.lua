local function on_attach(client, bufnr)
    -- Set autocommands conditional on server_capabilities
    vim.notify("Attached server " .. client.name, vim.log.levels.INFO, {
        title = "LSP",
    })

    local function disable_format_capability(capabilities)
        capabilities.documentFormattingProvider = false
        capabilities.documentRangeFormattingProvider = false
    end
    local ignored_fmt_lsps = {
        "lua_ls",
    }
    local capabilities = client.server_capabilities
    -- vim.notify(vim.inspect(capabilities))
    for _, lsp_name in ipairs(ignored_fmt_lsps) do
        if client.name == lsp_name then
            disable_format_capability(capabilities)
        end
    end

    if capabilities.semanticTokensProvider and capabilities.semanticTokensProvider.full then
        require("hlargs").disable_buf(bufnr)
    end
end

local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local server_opts = {
    capabilities = lsp_capabilities,
    on_attach = on_attach,
}

local lsp_server_bin_dir = vim.fn.stdpath("data") .. "/mason/bin/"
return {
    {
        url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        event = "LspAttach",
        keys = {
            {
                "<leader>lt",
                function()
                    require("lsp_lines").toggle()
                end,
                desc = "LSP: Toggle Diagnostic Appearance",
            },
            {
                "<leader>lt",
                function()
                    ---@diagnostic disable-next-line: undefined-field
                    local virtual_lines_enabled = not vim.diagnostic.config().virtual_lines
                    vim.diagnostic.config({
                        virtual_lines = virtual_lines_enabled,
                        virtual_text = not virtual_lines_enabled,
                    })
                end,
                desc = "LSP: Toggle Diagnostic Style",
            },
        },
        config = function()
            vim.diagnostic.config({
                virtual_text = false,
            })
            require("lsp_lines").setup()
        end,
    },
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
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
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
        ft = { "rust" },
        config = function()
            vim.g.rustaceanvim = {
                server = {
                    on_attach = on_attach,
                },
                dap = {
                    adapter = {
                        type = "server",
                        port = "${port}",
                        executable = {
                            command = "codelldb",
                            args = { "--port", "${port}" },
                        },
                    },
                },
                tools = {
                    executor = require("rustaceanvim.executors").termopen,
                    hover_actions = {
                        replace_builtin_hover = false,
                    },
                },
            }
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "Decodetalkers/csharpls-extended-lsp.nvim",
            {
                "williamboman/mason-lspconfig.nvim",
                opts = {

                    automatic_installation = true,
                    ensure_installed = {
                        "tsserver",
                    },
                },
            },
            {
                "nvim-java/nvim-java",
                dependencies = {
                    "nvim-java/lua-async-await",
                    "nvim-java/nvim-java-refactor",
                    "nvim-java/nvim-java-core",
                    "nvim-java/nvim-java-test",
                    "nvim-java/nvim-java-dap",
                    "MunifTanjim/nui.nvim",
                    "mfussenegger/nvim-dap",
                    "williamboman/mason.nvim",
                },
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
            "Hoffs/omnisharp-extended-lsp.nvim",
            "b0o/schemastore.nvim",
            {
                "m-demare/hlargs.nvim",
                event = { "BufReadPre", "BufNewFile" },
                config = true,
            },
            {
                "nvimtools/none-ls.nvim",
                config = function()
                    local null_ls = require("null-ls")
                    null_ls.setup({
                        sources = {
                            null_ls.builtins.formatting.stylua,
                            null_ls.builtins.formatting.asmfmt,
                            null_ls.builtins.formatting.black,
                            null_ls.builtins.formatting.typstfmt,
                            null_ls.builtins.formatting.cmake_format,
                            null_ls.builtins.formatting.shfmt,
                            null_ls.builtins.formatting.shellharden,
                            null_ls.builtins.formatting.prettierd,
                            null_ls.builtins.diagnostics.hadolint,
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
                            return not vim.list_contains({ "lua_ls" }, client.name)
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
            { "<leader>k", vim.lsp.buf.hover, desc = "LSP: Hover" },
            { "<leader>K", vim.lsp.buf.signature_help, desc = "LSP: Sig Help" },
            { "<leader>lR", ":LspRestart<CR>", desc = "LSP: Restart" },
            {
                "<leader>ls",
                function()
                    vim.diagnostic.open_float(nil, { focus = true, scope = "cursor" })
                    vim.cmd.vsplit()
                end,
                desc = "LSP: Diagnostic Open Float",
            },
            {
                "[l",
                function()
                    vim.diagnostic.jump({ count = -1 })
                end,
                desc = "LSP: Diagnostic Previous",
            },
            {
                "]l",
                function()
                    vim.diagnostic.jump({ count = 1 })
                end,
                desc = "LSP: Diagnostic Next",
            },
            {
                "<leader>lt",
                function()
                    ---@diagnostic disable-next-line: undefined-field
                    local virtual_lines_enabled = not vim.diagnostic.config().virtual_lines
                    vim.diagnostic.config({
                        virtual_lines = virtual_lines_enabled,
                        virtual_text = not virtual_lines_enabled,
                    })
                end,
                desc = "LSP: Toggle Diagnostic Style",
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
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = {
                    "tsserver",
                },
                handlers = {
                    ["jdtls"] = function()
                        require("java").setup({
                            notifications = {
                                dap = false,
                            },
                        })
                    end,
                },
            })

            local lspconfig = require("lspconfig")

            lspconfig.jdtls.setup({
                capabilities = lsp_capabilities,
                on_attach = on_attach,
                -- HACK: Have to define this to make jdtls show hovers, etc.
                init_options = {},
                settings = {
                    java = {
                        completion = {
                            postfix = {
                                enabled = true,
                            },
                        },
                        inlayHints = {
                            parameterNames = {
                                enabled = "all",
                                exclusions = { "this" },
                            },
                        },
                    },
                },
            })

            -- NOTE: ANSIBLE LSP
            -- I use ansible a lot, define exceptions for servers that can use
            -- server:setup & vim.cmd at the bottom here
            lspconfig.ansiblels.setup({
                capabilities = lsp_capabilities,
                on_attach = on_attach,
                settings = {
                    ansible = {
                        ansible = {
                            useFullyQualifiedCollectionNames = true,
                            path = "ansible",
                        },
                        ansibleLint = {
                            enabled = true,
                            path = "ansible-lint",
                        },
                        python = {
                            interpreterPath = "python3",
                        },
                        completion = {
                            provideRedirectModules = true,
                        },
                    },
                },
            })

            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        hint = {
                            enable = true,
                            setType = true,
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })

            -- NOTE: PYTHON LSP
            lspconfig.pyright.setup({
                python = {
                    analysis = {
                        diagnosticMode = "workspace",
                        typeCheckingMode = "strict",
                    },
                },
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            })

            lspconfig.yamlls.setup({
                settings = {
                    redhat = {
                        telemetry = {
                            enabled = false,
                        },
                    },
                    yaml = {
                        schemas = require("schemastore").yaml.schemas({
                            validate = { enable = true },
                            extra = {
                                {
                                    description = "Gitea Actions",
                                    fileMatch = ".gitea/workflows/*",
                                    name = "gitea-workflow.json",
                                    url = "https://json.schemastore.org/github-workflow.json",
                                },
                            },
                        }),
                    },
                },
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            })

            lspconfig.csharp_ls.setup({
                handlers = {
                    ["textDocument/definition"] = require("csharpls_extended").handler,
                },
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            })

            lspconfig.jsonls.setup({
                settings = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
                },
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            })

            lspconfig.docker_compose_language_service.setup({
                settings = {
                    telemetry = {
                        enableTelemetry = false,
                    },
                },
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            })

            lspconfig.powershell_es.setup({
                bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/",
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            })

            lspconfig.azure_pipelines_ls.setup({
                cmd = { lsp_server_bin_dir .. "azure-pipelines-language-server", "--stdio" },
                settings = {
                    redhat = {
                        telemetry = {
                            enabled = false,
                        },
                    },
                    yaml = {
                        schemas = {
                            ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
                                "*",
                            },
                        },
                    },
                },
                filetypes = { "azure-pipelines" },
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            })

            lspconfig.texlab.setup({
                capabilities = lsp_capabilities,
                on_attach = on_attach,
                settings = {
                    texlab = {
                        build = {
                            onSave = true,
                            executable = "tectonic",
                            forwardSearchAfter = true,
                            args = { "-X", "compile", "%f", "--synctex", "-Z", "continue-on-errors" },
                        },
                        forwardSearch = {
                            executable = "zathura",
                            args = { "--synctex-forward", "%l:1:%f", "%p" },
                        },
                    },
                },
            })

            lspconfig.gopls.setup({
                capabilities = lsp_capabilities,
                on_attach = on_attach,
                fillstruct = "gopls",
                dap_debug = true,
                dap_debug_gui = true,
            })

            lspconfig.nil_ls.setup({
                capabilities = lsp_capabilities,
                on_attach = on_attach,
                settings = {
                    ["nil"] = {
                        formatting = { command = { "nixfmt" } },
                        nix = {
                            maxMemoryMB = 60000,
                            flake = {
                                autoArchive = true,
                                autoEvalInputs = true,
                            },
                        },
                    },
                },
            })

            -- NOTE: GENERIC LSP SERVERS
            for _, server in ipairs({
                "clangd",
                "cmake",
                "bashls",
                "dockerls",
                "docker_compose_language_service",
                "eslint",
                "html",
                "cssls",
                "kotlin_language_server",
                "terraformls",
                "tflint",
                "vimls",
                "tsserver",
                "marksman",
                "asm_lsp",
                "typst_lsp",
                "nginx_language_server",
            }) do
                lspconfig[server].setup(server_opts)
            end
        end,
    },
}
