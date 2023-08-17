return {
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Trouble: Todo Items" },
        },
        cmd = {
            "TodoTrouble",
            "TodoTelescope",
            "TodoQuickFix",
            "TodoLocList",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = true,
    },
    {
        "folke/trouble.nvim",
        keys = {
            { "<leader>x", desc = "> Trouble" },
            { "<leader>lr", "<cmd>TroubleToggle lsp_references<cr>", desc = "LSP: References" },
            {
                "<leader>li",
                "<cmd>TroubleToggle lsp_implementations<cr>",
                desc = "LSP: Implementation",
            },
            { "<leader>ld", "<cmd>TroubleToggle lsp_definitions<CR>", desc = "LSP: Definition" },
            { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Trouble: Document Diagnostics" },
            { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Trouble: Loclist" },
            { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Trouble: Quickfix" },
            { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Trouble: Todo Items" },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup({
                auto_close = true,
                position = "right",
            })
            vim.api.nvim_create_autocmd("BufLeave", {
                pattern = "*Trouble*",
                callback = function()
                    vim.api.nvim_win_close(0, true)
                end,
            })
        end,
        cmd = {
            "Trouble",
            "TroubleClose",
            "TroubleToggle",
            "TroubleRefresh",
        },
    },
}