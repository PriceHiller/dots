return {
    {
        "lukas-reineke/headlines.nvim",
        dependencies = "nvim-treesitter/nvim-treesitter",
        opts = function()
            local bullets = {
                        "󰀘",
                        "",
                        "󰺕",
                        "",
                        "󰬪",
                        "󱆭",
            }
            return {
                markdown = {
                    bullets = bullets,
                },
                rmd = {
                    bullets = bullets,
                },
                norg = {
                    bullets = bullets
                },
                org = {
                    bullets = bullets
                }
            }
        end,
        config = true,
        ft = { "markdown", "norg", "rmd", "org" },
    },
}
