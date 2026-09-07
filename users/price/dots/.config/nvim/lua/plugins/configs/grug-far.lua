return {
    {
        "MagicDuck/grug-far.nvim",
        lazy = false,
        keys = {
            { "<leader>,", "<cmd>GrugFar<CR>", desc = "GrugFar: Open" },
        },
        config = function()
            require("grug-far").setup({})
        end,
    },
}
