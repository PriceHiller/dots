return {
    -- HACK: Yeah, I know there's two color plugins here. nvim-highlight-colors supports css variables and ccc.nvim
    -- does not. Ccc, on the other hand, ensures colors are ALWAYS shown even in split windows whereas
    -- nvim-highlight-colors does not 😦
    {
        "brenoprata10/nvim-highlight-colors",
        event = { "BufReadPre", "BufNewFile" },
        cmd = {
            "HighlightColorsOn",
            "HighlightColorsOff",
            "HighlightColorsToggle",
        },
        config = true,
    },{
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
                    lsp = true
                },
            })
        end,
    },
}
