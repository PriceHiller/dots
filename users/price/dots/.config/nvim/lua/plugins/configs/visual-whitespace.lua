return {
    {
        "mcauley-penney/visual-whitespace.nvim",
        event = "ModeChanged *:[vV]",
        opts = {
            highlight = { link = "visual-whitespace" },
            excluded = {
                filetypes = {
                    "snacks_picker_list",
                    "snacks_picker_input",
                    "snacks_picker_preview",
                }
            }
        },
    },
}
