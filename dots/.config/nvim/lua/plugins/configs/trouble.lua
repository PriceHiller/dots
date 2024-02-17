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
        opts = {
            keywords = {
                SECURITY = {
                    icon = "󰒃",
                    color = "warning",
                    alt = { "SEC", "SECURITY" },
                },
            },
        },
    },
    {
        "folke/trouble.nvim",
        keys = {
            { "<leader>x", desc = "> Trouble" },
            { "<leader>lr", "<cmd>Trouble lsp_references<cr>", desc = "LSP: References" },
            {
                "<leader>li",
                "<cmd>Trouble lsp_implementations<cr>",
                desc = "LSP: Implementation",
            },
            { "<leader>ld", "<cmd>Trouble lsp_definitions<CR>", desc = "LSP: Definition" },
            { "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", desc = "Trouble: Document Diagnostics" },
            { "<leader>xl", "<cmd>Trouble loclist<cr>", desc = "Trouble: Loclist" },
            { "<leader>xq", "<cmd>Trouble quickfix<cr>", desc = "Trouble: Quickfix" },
            { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Trouble: Todo Items" },
            { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Trouble: Toggle" },
        },
        event = { "QuickFixCmdPre" },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.api.nvim_create_autocmd("QuickFixCmdPost", {
                callback = function()
                    vim.cmd.TroubleRefresh()
                    vim.cmd.Trouble("quickfix")
                end,
            })
            -- HACK: Unfortuantely Neovim & Vim don't expose some C level functions to know when content in the
            -- quickfix has been updated 😢. A serious issue with this is that it just tries to refresh after 200ms,
            -- which may or may not work depending on how long the quickfix filtering took :/
            vim.api.nvim_create_autocmd({ "CmdlineLeave", "CmdwinLeave" }, {
                callback = function()
                    vim.defer_fn(vim.cmd.TroubleRefresh, 200)
                end,
            })
            require("trouble").setup({
                auto_open = false,
                auto_close = true,
                position = "right",
                action_keys = {
                    cancel = "q",
                },
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
