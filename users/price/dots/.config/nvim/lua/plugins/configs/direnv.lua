return {
    {
        "actionshrimp/direnv.nvim",
        lazy = false,
        config = function()
            local direnv = require("direnv-nvim")
            -- TODO: Make this properly restart LSP clients as necessary
            direnv.setup({
                async = true,
            })
        end,
    },
}
