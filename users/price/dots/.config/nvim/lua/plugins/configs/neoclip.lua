return {
    {
        "AckslD/nvim-neoclip.lua",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "kkharji/sqlite.lua", module = "sqlite" },
            { "nvim-telescope/telescope.nvim" },
        },
        opts = {
            enable_persistent_history = true,
        },
    },
}
