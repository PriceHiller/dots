return {
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        cmd = {
            "TodoTrouble",
            "TodoTelescope",
            "TodoQuickFix",
            "TodoLocList",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            keywords = {
                SECURITY = {
                    icon = "󰒃",
                    color = "warning",
                    alt = { "SEC", "SECURITY" },
                },
            },
        },
    },
}
