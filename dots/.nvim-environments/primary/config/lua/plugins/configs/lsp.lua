local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")
local async = require("plenary.async")

-- NOTE: Keep this near top
mason_lspconfig.setup({
    automatic_installation = true,
})

local function on_attach(client, bufnr)
    -- Set autocommands conditional on server_capabilities
    async.run(function()
        vim.notify
            .async("Attached server " .. client.name, "info", {
                title = "Lsp Attach",
            }).events
            .close()
    end)
end

local lsp_capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
local opts = {
    capabilities = lsp_capabilities,
    on_attach = on_attach,
}

local rust_tools = require("rust-tools")
local rustopts = {
    server = opts,
    dap = {
        adapter = {
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
        },
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
            auto = true,

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
                provideRedirectModules = false,
            },
        },
    },
})

-- NOTE: LUA LSP
local luadev = require("lua-dev").setup({
    lspconfig = opts,
})

lspconfig.sumneko_lua.setup(luadev)

-- NOTE: SQL LSP
lspconfig.sqls.setup({
    on_attach = function(client, bufnr)
        require("sqls").on_attach(client, bufnr)
        on_attach(client, bufnr)
    end,
})

-- NOTE: PYTHON LSP
lspconfig.pylsp.setup({
    filetypes = { "python" },
    settings = {
        formatCommand = { "black" },
        pylsp = {
            plugins = {
                jedi_completion = {
                    include_params = true,
                    fuzzy = true,
                    eager = true,
                },
                jedi_signature_help = { enabled = true },
                pyflakes = { enabled = true },
                pycodestyle = {
                    enabled = true,
                    ignore = { "E501", "E231", "W503", "E731" },
                    maxLineLength = 120,
                },
                mypy = { enabled = true },
                yapf = { enabled = true },
                rope_completion = {
                    enabled = true,
                    eager = true,
                },
            },
        },
    },
    capabilities = lsp_capabilities,
    on_attach = on_attach,
})

lspconfig.yamlls.setup({
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
                    "/azure-pipeline*.y*l",
                    "/*.azure",
                    "Azure-Pipelines/**/*.y*l",
                },
                ["https://raw.githubusercontent.com/docker/cli/master/cli/compose/schema/data/config_schema_v3.10.json"] = "/docker-compose.y*l",
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = "/.gitlab-ci.yml",
                ["https://json.schemastore.org/travis.json"] = "/.travis.y*l",
                ["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-inventory.json"] = {
                    "/inventories/*/*.y*l",
                    "/inventory/*.y*l",
                },
                ["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-vars.json"] = {
                    "playbooks/vars/*.y*l",
                    "vars/*.y*l",
                    "defaults/*.y*l",
                    "host_vars/*.y*l",
                    "group_vars/*.y*l",
                },
            },
        },
    },
    capabilities = lsp_capabilities,
    on_attach = on_attach,
})

-- lspconfig.csharp_ls.setup({
--     handlers = {
--         ["textDocument/definition"] = require("csharpls_extended").handler,
--     },
--     capabilities = lsp_capabilities,
--     on_attach = on_attach,
-- })

lspconfig.omnisharp.setup({
    cmd = {
        vim.fn.stdpath("data") .. "/mason/bin/omnisharp",
        "--languageserver",
        "--hostPID",
        tostring(vim.fn.getpid()),
    },

    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
    enable_import_completion = true,
    enable_roslyn_analyzers = true,
    organize_imports_on_format = true,
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

lspconfig.powershell_es.setup({
    bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/",
    capabilities = lsp_capabilities,
    on_attach = on_attach,
})

-- NOTE: GENERIC LSP SERVERS
for _, server in ipairs({
    "clangd",
    "cmake",
    "bashls",
    "dockerls",
    "eslint",
    "html",
    "cssls",
    "jdtls",
    "kotlin_language_server",
    "terraformls",
    "tflint",
    "tsserver",
    "vimls",
    "vuels",
    "tsserver",
    "pyright",
    "rnix",
    "marksman",
    "texlab",
    "ltex",
}) do
    lspconfig[server].setup(opts)
end
