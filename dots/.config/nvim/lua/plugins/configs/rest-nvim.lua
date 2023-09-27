return {
    {
        "rest-nvim/rest.nvim",
        ft = { "http" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter"
        },
        config = function ()
            require("rest-nvim").setup({})
        end
    }
}
