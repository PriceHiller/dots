return {
    ---@type lspconfig.settings.lua_ls
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
}
