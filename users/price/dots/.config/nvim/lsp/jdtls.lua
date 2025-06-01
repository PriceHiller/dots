return {
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
}
