return {
    {
        "AckslD/nvim-neoclip.lua",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "tami5/sqlite.lua" },
            { "nvim-telescope/telescope.nvim" },
        },
        opts = {
            enable_persistent_history = true,
        },
    },
}
