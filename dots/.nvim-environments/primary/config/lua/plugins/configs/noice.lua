require("noice").setup({
    cmdline = {
        format = {
            cmdline = { "^:", icon = "" },
        },
    },
    views = {
        cmdline_popup = {
            position = {
                row = "99%",
                col = "0%",
            },
            border = {
                style = "none",
                padding = { 0, 0 },
            },
        },
    },
})
