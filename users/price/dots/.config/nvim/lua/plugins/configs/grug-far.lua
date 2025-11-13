return {
    {
        "MagicDuck/grug-far.nvim",
        lazy = false,
        keys = {
            { ",,", "<cmd>GrugFar<CR>", desc = "GrugFar: Open" },
        },
        config = function()
            require("grug-far").setup({})
        end,
    },
}
