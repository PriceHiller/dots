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
                    query = vim.treesitter.query.parse(
                        "markdown",
                        [[
                            (atx_heading [
                                (atx_h1_marker)
                                (atx_h2_marker)
                                (atx_h3_marker)
                                (atx_h4_marker)
                                (atx_h5_marker)
                                (atx_h6_marker)
                            ] @headline)

                            (thematic_break) @dash

                            (fenced_code_block) @codeblock

                            (block_quote_marker) @quote
                            (block_quote (paragraph (inline (block_continuation) @quote)))
                            (block_quote (paragraph (block_continuation) @quote))
                            (block_quote (list (list_item (paragraph (inline (block_continuation) @quote)))))
                            (block_quote (block_continuation) @quote)
                        ]]
                    ),
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
        ft = { "markdown", "norg", "rmd", "org" },
    },
}
