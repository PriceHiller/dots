return {
    {
        "rachartier/tiny-glimmer.nvim",
        event = "VeryLazy",
        config = function()
            require("tiny-glimmer").setup({
                overwrite = {
                    yank = {
                        enabled = true,
                        default_animation = {
                            name = "fade",
                            settings = {
                                from_color = "Yank",
                            },
                        },
                    },
                    paste = {
                        enabled = true,
                        default_animation = {
                            name = "fade",
                            settings = {
                                from_color = "Paste",
                            },
                        },
                    },
                    undo = {
                        enabled = true,
                    },
                    redo = {
                        enabled = true,
                    },
                    search = {
                        enabled = true,
                    },
                },
            })
        end,
    },
}
