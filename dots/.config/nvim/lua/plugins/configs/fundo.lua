return {

    {
        "kevinhwang91/nvim-fundo",
        dependences = { "kevinhwang91/promise-async" },
        config = true,
        build = function()
            require("fundo").install()
        end,
    },
}
