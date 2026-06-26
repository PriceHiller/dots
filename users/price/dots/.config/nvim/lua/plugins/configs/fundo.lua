return {
    {
        "kevinhwang91/nvim-fundo",
        event = { "BufRead", "BufNewFile" },
        dependencies = { "kevinhwang91/promise-async" },
        config = true,
        build = function()
            require("fundo").install()
        end,
    },
}
