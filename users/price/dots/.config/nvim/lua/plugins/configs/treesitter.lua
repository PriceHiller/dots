---@diagnostic disable: missing-fields
---@type LazySpec
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
        opts = {
            snippet_engine = "nvim",
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
        "windwp/nvim-ts-autotag",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close_on_slash = true,
                },
            })
        end,
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local rainbow_delimiters = require("rainbow-delimiters")
            vim.g.rainbow_delimiters = {
                strategy = {
                    on_attach = function()
                        if vim.fn.line("$") > 100000 then
                            return nil
                        elseif vim.fn.line("$") > 10000 then
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
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                },
            }
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "FileType",
        keys = {
            {
                "[cc",
                function()
                    require("treesitter-context").go_to_context(vim.v.count1)
                end,
                desc = "TS Context: Go to Context",
            },
        },
        config = function()
            require("treesitter-context").setup({
                max_lines = 5,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        keys = (function()
            local move_config = {
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
            }

            ---@type LazyKeysSpec[]
            local keys = {}

            for move, binds in pairs(move_config) do
                for bind, query_string in pairs(binds) do
                    table.insert(keys, {
                        bind,
                        mode = { "n", "x", "o" },
                        function()
                            require("nvim-treesitter-textobjects.move")[move](query_string, "textobjects")
                        end,
                        desc = ("%s > %s"):format(move, query_string),
                    })
                end
            end

            local select_config = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["ib"] = "@block.inner",
                ["ab"] = "@block.outer",
            }

            for bind, query in pairs(select_config) do
                table.insert(keys, {
                    bind,
                    mode = { "x", "o" },
                    function()
                        require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
                    end,
                    desc = ("TS > %s"):format(query),
                })
            end
            table.insert(keys, {
                "as",
                mode = { "x", "o" },
                function()
                    require("nvim-treesitter-textobjects.select").select_textobject("@scope", "locals")
                end,
                desc = ("TS > %s"):format("@scope"),
            })

            return keys
        end)(),
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    enable = true,
                    lookahead = true,
                    include_surrounding_whitespace = true,
                    disable = function(_, _)
                        local mode = vim.fn.mode()
                        if mode == "c" then
                            return true
                        end
                    end,
                },
                move = {
                    enable = true,
                    set_jumps = true,
                },
            })
        end,
    },

    {
        "shushtain/nvim-treesitter-incremental-selection",
        keys = {
            {
                "<CR>",
                function()
                    require("nvim-treesitter-incremental-selection").init_selection()
                end,
            },
            {
                "<BS>",
                mode = { "v" },
                function()
                    require("nvim-treesitter-incremental-selection").decrement_node()
                end,
            },
            {
                "<CR>",
                mode = { "v" },
                function()
                    require("nvim-treesitter-incremental-selection").increment_node()
                end,
            },
        },
        config = function()
            local tsis = require("nvim-treesitter-incremental-selection")

            tsis.setup({
                ignore_injections = false,
                loop_siblings = false,
                fallback = true,
                quiet = false,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "main",
        event = { "BufReadPre", "BufNewFile", "WinLeave", "FileReadPre" },
        dependencies = {
            "RRethy/nvim-treesitter-endwise",
        },
        config = function()
            local ts = require("nvim-treesitter")

            -- Install _all_ available parsers
            vim.defer_fn(function()
                ts.install(ts.get_available())
            end, 50)
        end,
    },
}
