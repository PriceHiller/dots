return {
    {
        "willothy/flatten.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("flatten").setup({
                hooks = {
                    should_block = function()
                        return vim.env.NVIM_FLATTEN_BLOCK
                    end,
                },
                one_per = {
                    wezterm = false,
                    kitty = false,
                },
            })
        end,
    },
}
