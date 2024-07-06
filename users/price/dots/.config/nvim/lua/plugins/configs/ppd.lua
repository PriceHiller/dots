return {
    {
        "PriceHiller/ppd.nvim",
        config = function()
            require("ppd").setup()
            vim.cmd.cnoreabbrev("pushd", "Pushd")
            vim.cmd.cnoreabbrev("popd", "Popd")
        end,
    },
}
