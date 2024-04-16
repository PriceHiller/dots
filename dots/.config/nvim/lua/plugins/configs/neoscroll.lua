return {
    {
        "karb94/neoscroll.nvim",
        event = "WinScrolled",
        config = function(opts)
            if not vim.g.neovide then
                require("neoscroll").setup(opts)
            end
        end,
        opts = {
            easing_function = "quadratic",
        },
    },
}
