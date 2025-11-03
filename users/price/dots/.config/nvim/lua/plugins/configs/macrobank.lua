return {
    {
        "sahilsehwag/macrobank.nvim",
        lazy = false,
        keys = {
            { "<leader>m", desc = "> Macrobank" },
            {
                "<leader>mm",
                "<cmd>MacroBankLive<CR>",
                desc = "Macrobank: Edit macros",
            },
            {
                "<leader>me",
                "<cmd>MacroBank<CR>",
                desc = "Macrobank: Edit saved macros",
            },
        },
        config = function()
            require("macrobank").setup({
                store_path_global = vim.fn.stdpath("data") .. "/macrobank.json",
            })
        end,
    },
}
