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
        cmd = { "Increname" },
        keys = {
            { "<leader>ln", ":IncRename ", desc = "LSP: Rename" },
        },
        opts = {},
    },
    {
        "kosayoda/nvim-lightbulb",
        event = "LspAttach",
        dependencies = {
            "antoinemadec/FixCursorHold.nvim",
        },
        opts = function()
            local text_icon = ""
            local nvim_lightbulb = require("nvim-lightbulb")
            vim.fn.sign_define(
                "LightBulbSign",
                { text = text_icon, numhl = "DiagnosticSignHint", texthl = "DiagnosticSignHint", priority = 9 }
            )
            vim.api.nvim_create_autocmd("CursorHold,CursorHoldI", {
                callback = nvim_lightbulb.update_lightbulb,
            })
            return {
                sign = {
                    priority = 9,
                    text = text_icon,
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
            { "williamboman/mason.nvim", cmd = { "Mason" } },
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
        },
        keys = {
            { "<leader>l", desc = "> LSP" },
            {
                "<leader>lh",
                function()
                    if vim.diagnostic.is_disabled() then
                        vim.diagnostic.enable()
                    else
                        vim.diagnostic.disable()
                    end
                end,
                desc = "LSP: Toggle Diagnostics",
            },
            { "<leader>lD", vim.lsp.buf.declaration, desc = "LSP: Declaration" },
            { "<leader>k", vim.lsp.buf.hover, desc = "LSP: Hover" },
            { "<leader>K", vim.lsp.buf.signature_help, desc = "LSP: Sig Help" },
            { "<leader>lc", vim.lsp.buf.code_action, desc = "LSP: Code Action" },
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
                    local virtual_lines_enabled = not vim.diagnostic.config().virtual_lines
                    vim.diagnostic.config({
                        virtual_lines = virtual_lines_enabled,
                        virtual_text = not virtual_lines_enabled,
                    })
                end,
                desc = "LSP: Toggle Diagnostic Style",
            },
            {
                "<leader>lT",
                function()
                    vim.lsp.inlay_hint(0, nil)
                end,
                desc = "LSP: Toggle Inlay Hints",
            },
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("mason").setup({
                max_concurrent_installers = 12,
            })

            local mason_lspconfig = require("mason-lspconfig")
            local lspconfig = require("lspconfig")

            -- NOTE: Keep this near top
            mason_lspconfig.setup({
                automatic_installation = true,
                ensure_installed = {
                    "tsserver",
                },
            })

            local lsp_augroup = vim.api.nvim_create_augroup("lsp_augroup", { clear = true })
            local function on_attach(client, bufnr)
                -- Set autocommands conditional on server_capabilities
                vim.notify("Attached server " .. client.name, "info", {
                    title = "LSP",
                })

                local capabilities = client.server_capabilities
                -- Enable inlay hints if the language server provides them
                if capabilities.inlayHintProvider then
                    vim.api.nvim_create_autocmd("InsertEnter", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.inlay_hint(bufnr, true)
                        end,
                        group = lsp_augroup,
                    })
                    vim.api.nvim_create_autocmd("InsertLeave", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.inlay_hint(bufnr, false)
                        end,
                        group = lsp_augroup,
                    })
                end

                if capabilities.semanticTokensProvider and capabilities.semanticTokensProvider.full then
                    require("hlargs").disable_buf(bufnr)
                end
            end

            local lsp_capabilities =
                require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
            local opts = {
                capabilities = lsp_capabilities,
                on_attach = on_attach,
            }

            local lsp_server_bin_dir = vim.fn.stdpath("data") .. "/mason/bin/"
            local rust_tools = require("rust-tools")
            local codelldb_path = lsp_server_bin_dir .. "codelldb"
            local liblldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.so"
            local rustopts = {
                server = opts,
                dap = {
                    adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
                },
                tools = {
                    -- how to execute terminal commands
                    -- options right now: termopen / quickfix
                    executor = require("rust-tools/executors").termopen,
                    -- callback to execute once rust-analyzer is done initializing the workspace
                    -- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
                    on_initialized = nil,
                    -- These apply to the default RustSetInlayHints command
                    inlay_hints = {
                        -- automatically set inlay hints (type hints)
                        -- default: true
                        auto = false,
                        -- Only show inlay hints for the current line
                        only_current_line = false,
                        -- whether to show parameter hints with the inlay hints or not
                        -- default: true
                        show_parameter_hints = true,
                        -- prefix for parameter hints
                        -- default: "<-"
                        parameter_hints_prefix = "<- ",
                        -- prefix for all the other hints (type, chaining)
                        -- default: "=>"
                        other_hints_prefix = "=> ",
                        -- whether to align to the lenght of the longest line in the file
                        max_len_align = false,
                        -- padding from the left if max_len_align is true
                        max_len_align_padding = 1,
                        -- whether to align to the extreme right or not
                        right_align = false,
                        -- padding from the right if right_align is true
                        right_align_padding = 7,
                        -- The color of the hints
                        highlight = "Comment",
                    },
                    hover_actions = {
                        auto_focus = true,
                    },
                    server = {
                        on_attach = function(client, bufnr)
                            vim.keymap.set("n", "<leader>fr", rust_tools.runnables.runnables, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fd", rust_tools.debuggables.debuggables, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fp", rust_tools.parent_module.parent_module, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fJ", rust_tools.join_lines.join_lines, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fH", rust_tools.hover_range.hover_range, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fm", rust_tools.expand_macro.expand_macro, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fc", rust_tools.open_cargo_toml.open_cargo_toml, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fk", ":RustMoveItemUp<CR>", {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fj", ":RustMoveItemDown<CR>", {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fh", rust_tools.hover_actions.hover_actions, {
                                buffer = bufnr,
                            })

                            vim.keymap.set("n", "<leader>fa", rust_tools.code_action_group.code_action_group, {
                                buffer = bufnr,
                            })
                            on_attach(client, bufnr)
                        end,
                    },
                },
            }
            rust_tools.setup(rustopts)

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
                override = function(root_dir, library)
                    local cur_file = vim.api.nvim_buf_get_name(0)

                    if root_dir:find("/tmp", 1, true) == 1 then
                        library.enabled = true
                        library.plugins = true
                    end

                    if cur_file:find("%.nvim%.lua") ~= nil then
                        library.enabled = true
                        library.plugins = true
                    end
                end,
            })

            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            })

            -- NOTE: PYTHON LSP
            lspconfig.pyright.setup({
                capabilities = lsp_capabilities,
                on_attach = on_attach
            })

            lspconfig.yamlls.setup({
                settings = {
                    redhat = {
                        telemetry = {
                            enabled = false,
                        },
                    },
                    yaml = {
                        schemas = require("schemastore").yaml.schemas({}),
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

            -- lspconfig.omnisharp.setup({
            --     cmd = {
            --         vim.fn.stdpath("data") .. "/mason/bin/omnisharp",
            --         "--languageserver",
            --         "--hostPID",
            --         tostring(vim.fn.getpid()),
            --     },
            --
            --     handlers = {
            --         ["textDocument/definition"] = require("omnisharp_extended").handler,
            --     },
            --     enable_import_completion = true,
            --     enable_roslyn_analyzers = true,
            --     organize_imports_on_format = true,
            --     capabilities = lsp_capabilities,
            --     on_attach = on_attach,
            -- })

            lspconfig.jsonls.setup({
                settings = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
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
                            args = { "-X", "compile", "%f", "--synctex" },
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
                    tsserver_path = vim.fn.stdpath("data")
                        .. "/mason/packages/typescript-language-server/node_modules/typescript/lib/tsserver.js",
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
                settings = {
                    gopls = {
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
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
                "rnix",
                "marksman",
                "asm_lsp",
            }) do
                lspconfig[server].setup(opts)
            end

            -- Custom Servers outside of lspconfig
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "nginx",
                desc = "Nginx Language Server Handler",
                callback = function()
                    local client_id = vim.lsp.start({
                        name = "Nginx-ls",
                        cmd = { lsp_server_bin_dir .. "nginx-language-server" },
                        root_dir = vim.fn.getcwd(),
                        capabilities = lsp_capabilities,
                        on_attach = on_attach,
                    })

                    if client_id then
                        vim.lsp.buf_attach_client(0, client_id)
                    end
                end,
            })
        end,
    },
}
