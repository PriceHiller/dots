return {
    {
        "uga-rosa/ccc.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "<leader>kk", "<cmd>CccHighlighterToggle<CR>", desc = "Ccc: Toggle" },
        },
        config = function()
            local ccc = require("ccc")
            ccc.setup({
                pickers = {
                    ccc.picker.hex,
                    ccc.picker.css_rgb,
                    ccc.picker.css_hsl,
                    ccc.picker.css_oklab,
                    ccc.picker.css_oklch,
                    ccc.picker.ansi_escape(),
                },
                outputs = {
                    (function()
                        ccc.output.hex.setup({ uppercase = true })
                        return ccc.output.hex
                    end)(),
                    ccc.output.css_rgb,
                    ccc.output.css_hsl,
                    ccc.output.css_oklab,
                    ccc.output.css_oklch,
                },
                highlighter = {
                    auto_enable = true,
                    lsp = false,
                },
            })
        end,
    },
}
