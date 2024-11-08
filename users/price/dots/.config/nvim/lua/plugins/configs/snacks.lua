return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
            {
                "<leader>nd",
                function()
                    require("snacks").notifier.hide()
                end,
                desc = "Notifications: Dismiss",
            },
            {
                "<leader>nv",
                function()
                    require("snacks").notifier.show_history()
                end,
                desc = "Notifications: Search",
            },
        },
        config = function()
            local snacks = require("snacks")
            snacks.setup({
                bigfile = { enabled = true },
                debug = { enabled = true },
                notifier = {
                    enabled = true,
                    style = "compact",
                    margin = { top = 1 },
                },
                words = { enabled = true },
                statuscolumn = { enabled = false }
            })
            _G.bt = snacks.debug.backtrace
            _G.dd = snacks.debug.inspect
            vim.print = snacks.debug.inspect
        end,
    },
}
