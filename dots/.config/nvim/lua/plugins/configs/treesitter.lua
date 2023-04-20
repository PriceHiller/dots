local nvim_treesitter = require("nvim-treesitter.configs")

nvim_treesitter.setup({
    ensure_installed = { "norg" },
    highlight = {
        enable = true,
        disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
    },
    matchup = { enable = true },
    autotag = { enable = true },
    indent = { enable = true },
    rainbow = {
        enable = true,
        query = "rainbow-parens",
        strategy = {
            on_attach = function()
                if vim.fn.line("$") < 1000 then
                    require("ts-rainbow.strategy.local")
                elseif vim.fn.line("$") < 10000 then
                    require("ts-rainbow.strategy.global")
                end
            end,
        },
    },
})

require("treesitter-context").setup({})
vim.cmd.TSContextEnable()
