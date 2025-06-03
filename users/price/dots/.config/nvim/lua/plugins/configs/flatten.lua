return {
    {
        "willothy/flatten.nvim",
        priority = 1000,
        enabled = true,
        lazy = false,
        config = function()
            require("flatten").setup({
                hooks = {
                    should_block = function()
                        return vim.env.NVIM_FLATTEN_BLOCK ~= nil
                    end,
                    should_nest = function()
                        return vim.env.NVIM_FLATTEN_NEST ~= nil
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
