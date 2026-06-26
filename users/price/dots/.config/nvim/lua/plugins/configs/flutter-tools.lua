return {
    {
        "nvim-flutter/flutter-tools.nvim",
        lazy = false,
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            vim.api.nvim_create_autocmd("BufWinEnter", {
                pattern = "*Flutter Outline",
                callback = function(args)
                    local buf = args.buf
                    for _, winnr in ipairs(vim.fn.win_findbuf(buf)) do
                        local wo = vim.wo[winnr]
                        wo.winbar = ""
                        wo.wrap = false
                        wo.statuscolumn = ""
                        wo.foldcolumn = "0"
                        wo.number = false
                        wo.signcolumn = "no"
                    end
                end,
            })
            require("flutter-tools").setup({
                widget_guides = {
                    enabled = true,
                },
            })
        end,
    },
}
