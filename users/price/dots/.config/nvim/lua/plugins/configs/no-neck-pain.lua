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
            { "<localleader>b", "<cmd>NoNeckPain<cr>", desc = "NoNeckPain: Toggle" },
        },
    },
}
