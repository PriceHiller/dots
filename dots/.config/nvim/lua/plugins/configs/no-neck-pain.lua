return {
    {
        "shortcuts/no-neck-pain.nvim",
        opts = {
            width = 160,
        },
        cmd = {
            "NoNeckPain",
            "NoNeckPainResize",
            "NoNeckPainWidthDown",
            "NoNeckPainScratchPad",
            "NoNeckPainToggleLeftSide",
            "NoNeckPainToggleRightSide",
        },
        keys = {
            { "<leader>bb", "<cmd>NoNeckPain<cr>", desc = "NoNeckPain: Toggle" },
        },
    },
}
