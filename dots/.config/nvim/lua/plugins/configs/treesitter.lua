local nvim_treesitter = require("nvim-treesitter.configs")

local treesitter_dir = vim.fn.stdpath("data") .. "/treesitter"

vim.opt.runtimepath:append(treesitter_dir)

nvim_treesitter.setup({
    parser_install_dir = treesitter_dir,
    ensure_installed = {
        "norg",
        "lua",
        "vim",
        "toml",
        "rust",
        "python",
        "c_sharp",
        "yaml",
        "json",
        "html",
        "markdown",
        "markdown_inline",
        "regex",
        "bash",
    },
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
    autotag = {
        enable = true,
    },
    indent = { enable = true },
    rainbow = {
        enable = true,
        query = {
            "rainbow-parens",
            html = "rainbow-tags",
            latex = "rainbow-blocks",
            tsx = "rainbow-tags",
            vue = "rainbow-tags",
            javascript = "rainbow-parens-react",
        },
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
