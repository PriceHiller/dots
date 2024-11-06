return {
    {
        "HakonHarnes/img-clip.nvim",
        cmd = {
            "PasteImage",
            "ImgClipDebug",
            "ImgClipConfig",
        },
        keys = {
            { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste Image" },
        },
        config = function()
            require("img-clip").setup({
                relative_to_current_file = true,
            })
        end,
    },
}
