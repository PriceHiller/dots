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
            local bullet_highlights = {
                "@markup.heading.1.marker",
                "@markup.heading.2.marker",
                "@markup.heading.3.marker",
                "@markup.heading.4.marker",
                "@markup.heading.5.marker",
                "@markup.heading.6.marker",
                "@markup.heading.7.marker",
                "@markup.heading.8.marker"
            }
            return {
                markdown = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights
                },
                rmd = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights
                },
                norg = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights
                },
                org = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights
                }
            }
        end,
        config = true,
        ft = { "markdown", "norg", "rmd", "org" },
    },
}
