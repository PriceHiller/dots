return {
    {
        "chrishrb/gx.nvim",
        keys = {
            { "gx", "<cmd>Browse<CR>", desc = "Open filepath or URI" },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = true, -- default settings
    },
}
