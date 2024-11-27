return {
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar" },
        keys = {
            { ",,", "<cmd>GrugFar<CR>", desc = "GrugFar: Open" },
        },
        config = function()
            require("grug-far").setup({})
        end,
    },
}
