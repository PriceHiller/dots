local nvim_treesitter = require('nvim-treesitter.configs')

nvim_treesitter.setup({
    ensure_installed = {
        'norg',
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        disable = { 'yaml' },
    },
    matchup = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
    yati = {
        enable = true,
    },
})
