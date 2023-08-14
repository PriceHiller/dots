return {
    {
        "uga-rosa/ccc.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("plugins.configs.ccc")
        end,
    },
}
