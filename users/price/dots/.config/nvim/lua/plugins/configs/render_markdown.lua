return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        config = function()
            require("render-markdown").setup({
                anti_conceal = {
                    enabled = true,
                },
                heading = {
                    foregrounds = {
                        "@markup.heading.1",
                        "@markup.heading.2",
                        "@markup.heading.3",
                        "@markup.heading.4",
                        "@markup.heading.5",
                        "@markup.heading.6",
                    },
                    backgrounds = {
                        "@markup.heading.1.bg",
                        "@markup.heading.2.bg",
                        "@markup.heading.3.bg",
                        "@markup.heading.4.bg",
                        "@markup.heading.5.bg",
                        "@markup.heading.6.bg",
                    },
                    border = true,
                },
                bullet = {
                    highlight = "@markup.list.markdown",
                },
                quote = {
                    -- repeat_linebreak = true,
                    highlight = {
                        "@markup.heading.1",
                        "@markup.heading.2",
                        "@markup.heading.3",
                        "@markup.heading.4",
                        "@markup.heading.5",
                        "@markup.heading.6",
                    },
                },
                pipe_table = {
                    head = "@markup.heading.1",
                    row = "@markup.heading.1",
                },
                completions = { lsp = { enabled = true } },
                file_types = { "markdown", "opencode_output" },
            })
        end,
        ft = { "markdown", "opencode_output" },
    },
}
