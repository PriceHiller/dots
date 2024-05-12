return {
    {
        "uga-rosa/ccc.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local ccc = require("ccc")
            ccc.setup({
                pickers = {
                    ccc.picker.hex,
                    ccc.picker.css_rgb,
                    ccc.picker.css_hsl,
                },
                highlighter = {
                    auto_enable = true,
                    lsp = true,
                },
            })
        end,
    },
}
