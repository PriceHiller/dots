return {
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = function()
            local g = vim.g

            g.indent_blankline_char = "▏"
            g.indent_blankline_context_char = "▏"

            -- Disable indent-blankline on these pages.
            g.indent_blankline_filetype_exclude = {
                "help",
                "terminal",
                "alpha",
                "packer",
                "lsp-installer",
                "lspinfo",
                "mason.nvim",
                "mason",
                "man",
                "OverseerForm",
                "noice",
                "lazy",
                "NeogitStatus",
                "NeogitHelpPopup",
                "NeogitPopup",
                "NeogitLogView",
            }

            g.indent_blankline_buftype_exclude = { "terminal" }
            g.indent_blankline_show_trailing_blankline_indent = false
            g.indent_blankline_show_first_indent_level = true

            return {
                show_current_context = true,
                show_current_context_start = true,
            }
        end,
    },
}
