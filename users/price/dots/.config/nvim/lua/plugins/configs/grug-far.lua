return {
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar" },
        keys = {
            { "<localleader><localleader>", "<cmd>GrugFar<CR>", desc = "GrugFar: Open" },
        },
        config = function()
            require("grug-far").setup({})
        end,
    },
}
