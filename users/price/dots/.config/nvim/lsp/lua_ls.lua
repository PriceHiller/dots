-- HACK: Ensure lazydev is loaded before `lua_ls` is setup
pcall(require, "lazydev")

return {
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
