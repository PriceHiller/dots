return {
    {
        "lukas-reineke/headlines.nvim",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            local bullets = {
                "󰪥",
                "󰀘",
                "󰺕",
                "",
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
                "@markup.heading.8.marker",
            }
            local headlines = require("headlines")
            headlines.setup({
                markdown = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights,
                    fat_headline_lower_string = "▀",
                },
                rmd = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights,
                    fat_headline_lower_string = "▀",
                },
                norg = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights,
                    fat_headline_lower_string = "▀",
                },
                org = {
                    bullets = bullets,
                    bullet_highlights = bullet_highlights,
                    fat_headline_lower_string = "▀",
                },
            })
            -- TODO: Upstream this fix to headlines.nvim
            vim.api.nvim_create_autocmd("VimResized", {
                callback = headlines.refresh,
            })
        end,
        ft = { "norg", "rmd", "org", "markdown" },
    },
}
