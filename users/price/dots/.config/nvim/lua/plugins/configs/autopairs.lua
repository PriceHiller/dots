return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")

            npairs.setup({
                check_ts = true,
                ts_config = {
                    typst = { "formula", "math", "raw_blck", "blob" },
                    markdown = { "latex_block", "code_span", "fenced_code_block" },
                },
            })
        end,
    },
}
