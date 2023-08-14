return {
    {
        "ldelossa/gh.nvim",
        cmd = { "GH" },
        dependencies = { "ldelossa/litee.nvim" },
        config = function()
            require("litee.lib").setup()
            require("litee.gh").setup({
                refresh_interval = 60000,
            })
        end,
    },
}
