return {
    "noamsto/resolved.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "Resolved" },
    config = function()
        require("resolved").setup({})
    end,
}
