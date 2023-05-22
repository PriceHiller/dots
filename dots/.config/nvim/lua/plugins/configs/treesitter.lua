local nvim_treesitter = require("nvim-treesitter.configs")

local treesitter_dir = vim.fn.stdpath("data") .. "/treesitter"

vim.opt.runtimepath:append(treesitter_dir)

nvim_treesitter.setup({
    parser_install_dir = treesitter_dir,
    ensure_installed = "all",
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
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            disable = function(lang, bufnr)
                local mode = vim.fn.mode()
                if mode == "c" then
                    return true
                end
            end,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ib"] = "@block.inner",
                ["ab"] = "@block.outer",
                ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
        },
        move = {
            enable = true,
            disable = function(lang, bufnr)
                local mode = vim.fn.mode()
                if mode == "c" then
                    return true
                end
            end,
            set_jumps = true,
            goto_next_start = {
                ["]fs"] = "@function.outer",
                ["]cs"] = "@class.outer",
                ["]bs"] = "@block.outer",
            },
            goto_next_end = {
                ["]fe"] = "@function.outer",
                ["]ce"] = "@class.outer",
                ["]be"] = "@block.outer",
            },
            goto_previous_start = {
                ["[fs"] = "@function.outer",
                ["[cs"] = "@class.outer",
                ["[bs"] = "@block.outer",
            },
            goto_previous_end = {
                ["[fe"] = "@function.outer",
                ["[ce"] = "@class.outer",
                ["[bs"] = "@block.outer",
            },
        },
    },
})

require("treesitter-context").setup({})
vim.cmd.TSContextEnable()
