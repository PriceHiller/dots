return {
    {
        "mcauley-penney/visual-whitespace.nvim",
        config = function()
            require("visual-whitespace").setup({
                excluded = {
                    filetypes = {
                        "snacks_picker_list",
                        "snacks_picker_input",
                        "snacks_picker_preview",
                    },
                    buftypes = {
                        "terminal",
                    },
                },
            })
        end,
    },
}
