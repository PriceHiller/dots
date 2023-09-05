return {

    {
        "kevinhwang91/nvim-fundo",
        event = { "BufReadPre", "BufNewFile" },
        dependences = { "kevinhwang91/promise-async" },
        config = true,
        build = function()
            require("fundo").install()
        end,
    },
}
