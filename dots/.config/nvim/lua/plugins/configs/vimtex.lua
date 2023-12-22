return {
    {
        "lervag/vimtex",
        ft = "tex",
        config = function()
            vim.g.vimtext_view_method = "zathura"
            vim.g.vimtex_view_general_viewer = "zathura"
            vim.g.vimtex_syntax_conceal_disable = true
        end,
    },
}
