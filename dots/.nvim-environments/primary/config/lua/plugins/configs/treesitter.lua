local nvim_treesitter = require("nvim-treesitter.configs")

nvim_treesitter.setup({
    ensure_installed = {
        "norg",
    },
    highlight = {
        enable = true,
    },
    matchup = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
    rainbow = {
        enable = true,
        query = "rainbow-parens",
        strategy = {
            on_attach = function()
                if vim.fn.line('$') < 1000 then
                    require("ts-rainbow.strategy.local")
                elseif vim.fn.line('$') < 10000 then
                    require("ts-rainbow.strategy.global")
                end
            end
        },
    },
})

require("treesitter-context").setup({})
vim.cmd.TSContextEnable()
