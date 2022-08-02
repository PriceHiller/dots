local loaded, mason_lspconfig = pcall(require, "mason-lspconfig")
if not loaded then
    return
end

local lspconfig_loaded, lspconfig = pcall(require, "lspconfig")
if not lspconfig_loaded then
    return
end

local plenary_loaded, async = pcall(require, "plenary.async")
if not plenary_loaded then
    return
end

local cmp_nvim_lsp_loaded, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_loaded then
    return
end

local rust_tools_loaded, rust_tools = pcall(require, "rust_tools")
if not rust_tools_loaded then
    return
end

local lua_dev_loaded, lua_dev = pcall(require, "lua-dev")
if not lua_dev_loaded then
    return
end

local sqls_loaded, sqls = pcall(require, "sqls")
if not sqls_loaded then
    return
end

local chsarpls_extended_loaded, csharpls_extended = pcall(require, "csharpls_extended")
if not csharpls_extended_loaded then
    return
end

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

local lsp_capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
local opts = {
    capabilities = lsp_capabilities,
    on_attach = on_attach,
}

-- INFO: RUST LSP
-- In the scenario we're using rust it makes more sense to use rust-tools
-- see: https://github.com/williamboman/nvim-lsp-installer/wiki/Rust
--
-- NOTE: Requires rust_analyzer
--
-- Dap installation, required vscode and the following extension to be installed:
-- https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb
--
-- locate it with `find ~/ -name `
local extension_path = os.getenv("HOME") .. "/.vscode/extensions/vadimcn.vscode-lldb-1.6.10/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"

local rustopts = {
    server = opts,
    dap = {
        adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
    },
    tools = {
        hover_actions = { auto_focus = true },
        crate_graph = {
            backend = "svg",
            output = "Rust-Crate-Graph-" .. os.time() .. ".svg",
        },
    },
}
rust_tools.setup(rustopts)

-- NOTE: ANSIBLE LSP
-- I use ansible a lot, define exceptions for servers that can use
-- server:setup & vim.cmd at the bottom here
lspconfig.ansiblels.setup({
    opts,
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
local luadev = lua_dev.setup({
    lspconfig = opts,
})

lspconfig.sumneko_lua.setup(luadev)

-- NOTE: SQL LSP
lspconfig.sqls.setup({
    on_attach = function(client, bufnr)
        sqls.on_attach(client, bufnr)
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

lspconfig.csharp_ls.setup({
    handlers = {
        ["textDocument/definition"] = csharpls_extended.handler,
    },
    capabilities = lsp_capabilities,
    on_attach = on_attach,
})

lspconfig.bashls.setup({})

-- NOTE: GENERIC LSP SERVERS
for _, server in ipairs({
    "clangd",
    "cmake",
    "dockerls",
    "eslint",
    "html",
    "jdtls",
    "kotlin_language_server",
    "terraformls",
    "tflint",
    "tsserver",
    "vimls",
    "vuels",
    "tsserver",
    "jsonls",
    "pyright",
}) do
    lspconfig[server].setup(opts)
end
