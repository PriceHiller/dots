return {
    ---@type lspconfig.settings.yamlls
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
}
