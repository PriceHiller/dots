return {
    {
        "gaoDean/autolist.nvim",
        event = { "BufReadPre", "BufNewFile" },
        ft = {
            "markdown",
            "text",
            "tex",
            "plaintex",
            "norg",
        },
        config = function()
            require("autolist").setup({})
            local autolist_group = vim.api.nvim_create_augroup("Autolist", {})
            vim.api.nvim_create_autocmd("filetype", {
                group = autolist_group,
                pattern = {
                    "markdown",
                    "text",
                    "tex",
                    "plaintex",
                    "norg",
                },
                callback = function()
                    if pcall(require, "autolist") then
                        vim.keymap.set(
                            "i",
                            "<tab>",
                            "<cmd>AutolistTab<cr>",
                            { silent = true, desc = "Autolist: Tab", buffer = true }
                        )
                        vim.keymap.set(
                            "i",
                            "<s-tab>",
                            "<cmd>AutolistShiftTab<cr>",
                            { silent = true, desc = "Autolist: Shift Tab", buffer = true }
                        )
                        vim.keymap.set(
                            "i",
                            "<CR>",
                            "<CR><cmd>AutolistNewBullet<cr>",
                            { silent = true, desc = "Autolist: New Bullet", buffer = true }
                        )
                        vim.keymap.set(
                            "n",
                            "o",
                            "o<cmd>AutolistNewBullet<cr>",
                            { silent = true, desc = "Autolist: New Bullet", buffer = true }
                        )
                        vim.keymap.set(
                            "n",
                            "O",
                            "O<cmd>AutolistNewBulletBefore<cr>",
                            { silent = true, desc = "Autolist: New Bullet Before", buffer = true }
                        )
                        vim.keymap.set(
                            "n",
                            "<C-CR>",
                            "<cmd>AutolistToggleCheckbox<cr>",
                            { silent = true, desc = "Autolist: Toggle Checkbox", buffer = true }
                        )

                        -- functions to recalculate list on edit
                        vim.keymap.set(
                            "n",
                            ">>",
                            ">><cmd>AutolistRecalculate<cr>",
                            { silent = true, desc = "Autolist: Indent", buffer = true }
                        )
                        vim.keymap.set(
                            "n",
                            "<<",
                            "<<<cmd>AutolistRecalculate<cr>",
                            { silent = true, desc = "Autolist: Dedent", buffer = true }
                        )
                        vim.keymap.set(
                            "n",
                            "dd",
                            "dd<cmd>AutolistRecalculate<cr>",
                            { silent = true, desc = "Autolist: Delete", buffer = true }
                        )
                        vim.keymap.set(
                            "v",
                            "d",
                            "d<cmd>AutolistRecalculate<cr>",
                            { silent = true, desc = "Autolist: Delete", buffer = true }
                        )
                    end
                end,
            })
        end,
    },
}
