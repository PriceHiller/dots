return {
    {
        "chrisgrieser/nvim-scissors",
        dependencies = "folke/snacks.nvim",
        config = function()
            require("scissors").setup({
                snippetDir = vim.fn.stdpath("config") .. "/snippets",
                editSnippetPopup = {
                    height = 0.85,
                    width = 0.90
                },
                jsonFormatter = "jq"
            })
        end
    },
}
