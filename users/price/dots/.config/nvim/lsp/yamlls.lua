local require_proxy = require("utils.funcs").require_proxy

return {
    ---@type lspconfig.settings.yamlls
    settings = {
        redhat = {
            telemetry = {
                enabled = false,
            },
        },
        yaml = {
            schemas = require_proxy("schemastore").yaml.schemas({
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
}
