return {
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap",
            "mfussenegger/nvim-dap-python",
            "nvim-telescope/telescope.nvim",
        },
        branch = "regexp",
        config = function()
            require("venv-selector").setup({
                settings = {
                    options = {
                        notify_user_on_venv_activation = true,
                    },
                },
            })
        end,
        ft = "python",
        cmd = {
            "VenvSelect",
        },
    },
}
