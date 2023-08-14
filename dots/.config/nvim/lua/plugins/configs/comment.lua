return {
    {
        "terrortylor/nvim-comment",
        cmd = "CommentToggle",
        config = function()
            require("nvim_comment").setup({})
        end,
        keys = {
            { "<leader>/", "<cmd>CommentToggle<CR>", desc = "Toggle Comment"},
            { "<leader>/", ":'<,'>CommentToggle<CR>", desc = "Toggle Selection Comment", mode = { "v" } },
        },
    },
}
