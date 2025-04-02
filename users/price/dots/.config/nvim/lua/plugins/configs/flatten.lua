return {
    {
        "willothy/flatten.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("flatten").setup({
                one_per = {
                    wezterm = false,
                    kitty = false,
                },
            })
        end,
    },
}
