return {
    "noamsto/resolved.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
        require("resolved").setup({})
    end,
}
