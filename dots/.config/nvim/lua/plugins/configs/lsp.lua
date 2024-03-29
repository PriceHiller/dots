local lsp_augroup = vim.api.nvim_create_augroup("lsp_augroup", { clear = true })
local function on_attach(client, bufnr)
    -- Set autocommands conditional on server_capabilities
    vim.notify("Attached server " .. client.name, "info", {
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
    -- Enable inlay hints if the language server provides them
    if capabilities.inlayHintProvider then
        vim.api.nvim_create_autocmd("InsertEnter", {
            buffer = bufnr,
            callback = function()
                vim.lsp.inlay_hint.enable(bufnr, true)
            end,
            group = lsp_augroup,
        })
        vim.api.nvim_create_autocmd("InsertLeave", {
            buffer = bufnr,
            callback = function()
                vim.lsp.inlay_hint.enable(bufnr, false)
            end,
            group = lsp_augroup,
        })
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
        config = true,
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
                    require("actions-preview").code_actions()
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
            "folke/neodev.nvim",
            "Decodetalkers/csharpls-extended-lsp.nvim",
            "williamboman/mason-lspconfig.nvim",
            {
                "williamboman/mason.nvim",
                cmd = {
                    "Mason",
                    "MasonLog",
                    "MasonUpdate",
                    "MasonInstall",
                    "MasonUninstall",
                    "MasonUninstallAll",
                },
                opts = {
                    max_concurrent_installers = 12,
                },
            },
            "simrat39/rust-tools.nvim",
            "Hoffs/omnisharp-extended-lsp.nvim",
            "b0o/schemastore.nvim",
            {
                "pmizio/typescript-tools.nvim",
                build = "npm i -g @styled/typescript-styled-plugin typescript",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
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
                    local curr_buf = vim.api.nvim_get_current_buf()
                    if vim.diagnostic.is_disabled(curr_buf) then
                        vim.diagnostic.enable(curr_buf)
                    else
                        vim.diagnostic.disable(curr_buf)
                    end
                end,
                desc = "LSP: Toggle Diagnostics in Current Buffer",
            },
            { "<leader>lD", vim.lsp.buf.declaration, desc = "LSP: Declaration" },
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
            { "[l", vim.diagnostic.goto_prev, desc = "LSP: Diagnostic Previous" },
            { "]l", vim.diagnostic.goto_next, desc = "LSP: Diagnostic Next" },
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
                    vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled(0))
                end,
                desc = "LSP: Toggle Inlay Hints",
            },
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local mason_lspconfig = require("mason-lspconfig")
            local lspconfig = require("lspconfig")

            -- NOTE: Keep this near top
            mason_lspconfig.setup({
                automatic_installation = true,
                ensure_installed = {
                    "tsserver",
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

            -- NOTE: LUA LSP
            require("neodev").setup({
                override = function(root_dir, options)
                    local cur_file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

                    if root_dir:find("/tmp", 1, true) == 1 then
                        options.enabled = true
                        options.plugins = true
                    end

                    local config_path = vim.fn.stdpath("config")
                    config_path = (config_path and vim.fn.resolve(config_path) or "")
                    if cur_file:find("^" .. vim.pesc(config_path) .. ".*") then
                        options.enabled = true
                        options.plugins = true
                    end

                    if cur_file:find("%.nvim%.lua") ~= nil then
                        options.enabled = true
                        options.plugins = true
                    end
                end,
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
                        schemaStore = {
                            enable = false,
                            url = "",
                        },
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

            -- Custom config from typescript tools
            require("typescript-tools").setup({
                on_attach = on_attach,
                settings = {
                    expose_as_code_action = {
                        "fix_all",
                        "add_missing_imports",
                        "remove_unused",
                        "remove_unused_imports",
                        "organize_imports",
                    },
                    tsserver_plugins = {
                        "@styled/typescript-styled-plugin",
                    },
                    tsserver_file_preferences = {
                        includeInlayParameterNameHints = "all",
                        includeInlayEnumMemberValueHints = true,
                        includeInlayFunctionLikeReturnTypeHints = true,
                        includeInlayFunctionParameterTypeHints = true,
                        includeInlayPropertyDeclarationTypeHints = true,
                        includeInlayVariableTypeHints = true,
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
                "jdtls",
                "kotlin_language_server",
                "terraformls",
                "tflint",
                "vimls",
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
