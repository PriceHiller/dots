require("noice").setup({
    cmdline = {
        view = "cmdline",
    },
    routes = {
        {
            filter = {
                event = "cmdline",
                find = "^%s*[/?]",
            },
            view = "cmdline",
        },
    },
})
