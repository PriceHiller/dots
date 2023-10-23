return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            vim.opt.timeoutlen = 250
            local wk = require("which-key")
            wk.setup()
        end,
    },
}
