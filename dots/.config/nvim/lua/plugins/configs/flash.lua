return {
    {
        "folke/flash.nvim",
        opts = {
            jump = {
                autojump = true,
                nohlsearch = true
            },
            label = {
                uppercase = false,
                style = "overlay",
            },
            char = {
                enabled = false
            }
        },
        keys = {
            { "/" },
            { "?" },
            {
                "<c-s>",
                mode = { "c" },
                function() require("flash").toggle() end,
                desc =
                "Toggle Flash Search"
            },
        },
    },
}
