---@diagnostic disable: missing-fields
return {
    {
        "danymat/neogen",
        keys = {
            { "<leader>ng", desc = "> Neogen" },
            { "<leader>ngf", "<cmd>Neogen func<CR>", desc = "Neogen: Function Annotation" },
            { "<leader>ngc", "<cmd>Neogen class<CR>", desc = "Neogen: Class Annotation" },
            { "<leader>ngt", "<cmd>Neogen type<CR>", desc = "Neogen: Type Annotation" },
            { "<leader>ngb", "<cmd>Neogen file<CR>", desc = "Neogen: File Annotation" },
        },
        cmd = {
            "Neogen",
        },
        dependencies = "nvim-treesitter/nvim-treesitter",
        opts = {
            snippet_engine = "luasnip",
            languages = {
                cs = {
                    template = {
                        annotation_convention = "xmldoc",
                    },
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("treesitter-context").setup({
                max_lines = 3,
            })
            vim.cmd.TSContextEnable()
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            filetypes = {
                "astro",
                "glimmer",
                "handlebars",
                "html",
                "javascript",
                "jsx",
                "php",
                "rescript",
                "svelte",
                "tsx",
                "typescript",
                "vue",
                "xml",
            },
        },
        ft = {
            "astro",
            "glimmer",
            "handlebars",
            "html",
            "javascript",
            "jsx",
            "php",
            "rescript",
            "svelte",
            "tsx",
            "typescript",
            "vue",
            "xml",
        },
    },
    {
        url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local rainbow_delimiters = require("rainbow-delimiters")
            vim.g.rainbow_delimiters = {
                strategy = {
                    on_attach = function()
                        if vim.fn.line("$") > 10000 then
                            return nil
                        elseif vim.fn.line("$") > 1000 then
                            return rainbow_delimiters.strategy["global"]
                        end
                        return rainbow_delimiters.strategy["local"]
                    end,
                },
                query = {
                    [""] = "rainbow-delimiters",
                    lua = "rainbow-blocks",
                    latex = "rainbow-blocks",
                    html = "rainbow-blocks",
                    javascript = "rainbow-delimiters-react",
                    tsx = "rainbow-parens",
                    verilog = "rainbow-blocks",
                },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            }
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile", "WinLeave" },
        dependencies = {
            "nvim-treesitter/playground",
            {
                "pfeiferj/nvim-hurl",
                config = true,
            },
            "nvim-treesitter/nvim-treesitter-textobjects",
            "RRethy/nvim-treesitter-endwise",
        },
        config = function()
            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            parser_config.typst = {
                install_info = {
                    url = "https://github.com/uben0/tree-sitter-typst",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "master",
                    generate_requires_npm = true,
                },
                maintainers = { "uben0" },
                experimental = true,
            }
            require("nvim-treesitter.configs").setup({
                auto_install = true,
                ignore_install = { "comment" },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<CR>",
                        scope_incremental = "<S-CR>",
                        node_incremental = "<CR>",
                        node_decremental = "<BS>",
                    },
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = { "org" },
                    disable = function(_, buf)
                        local disabled_filetypes = {
                            "tex",
                            "log",
                        }

                        for _, ft in ipairs(disabled_filetypes) do
                            if vim.bo.filetype == ft then
                                return true
                            end
                        end

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
                indent = {
                    enable = true,
                    disable = { "lua", "org" },
                },
                playground = {
                    enable = true,
                },
                query_linter = {
                    enable = true,
                },
                endwise = {
                    enable = true,
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
                    include_surrounding_whitespace = true,
                },
            })
        end,
    },
}
