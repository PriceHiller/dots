vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(args)
        vim.keymap.set("n", "q", function()
            require("snacks").bufdelete.delete({ force = true })
        end, { silent = true, buffer = args.buf, remap = true, desc = "Close Terminal Buffer" })
    end,
})

return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
            {
                "<A-x>",
                function()
                    require("snacks").bufdelete.delete()
                end,
                desc = "Close Buffer",
                mode = { "", "!", "v" },
            },

            {
                "<A-x>",
                function()
                    require("snacks").bufdelete.delete({ force = true })
                end,
                desc = "Close Buffer",
                mode = { "t" },
            },
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
                    require("snacks").notifier.show_history({
                        sort = { "added" },
                    })
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
                statuscolumn = { enabled = false },
            })
            snacks.config.styles["notification.history"] = {
                title = { { "Notification History", "@markup.heading.4" } },
                border = { { " ", "INVALIDHIGHLIGHTHERE" } },
            }
            _G.bt = snacks.debug.backtrace
            _G.dd = snacks.debug.inspect
            vim.print = snacks.debug.inspect
        end,
    },
}
