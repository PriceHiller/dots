---@param fun fun()
local function wrap_neotest_flatten_nest(fun)
    local old = vim.env.NVIM_FLATTEN_NEST
    vim.env.NVIM_FLATTEN_NEST = 1
    fun()
    vim.env.NVIM_FLATTEN_NEST = old
end
return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-go",
            "mrcjkb/rustaceanvim",
            "nvim-neotest/neotest-plenary",
        },
        keys = {
            { "<leader>t", desc = "> Neotest" },
            {
                "<leader>tr",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest run")
                    end)
                end,
                desc = "Neotest: Run Test",
            },
            {
                "<leader>tf",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest run file")
                    end)
                end,
                desc = "Neotest: Run Test(s) in File",
            },
            {
                "<leader>tl",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest run last")
                    end)
                end,
                desc = "Neotest: Run Last Test(s)",
            },
            {
                "<leader>tp",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest output-panel")
                    end)
                end,
                desc = "Neotest: Output Panel",
            },
            {
                "<leader>to",
                function()
                    local neotest = require("neotest")
                    vim.env.NVIM_FLATTEN_BLOCK = neotest.output.open({ enter = true })
                end,
                desc = "Neotest: Output",
            },
            {
                "<leader>tt",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest summary toggle")
                    end)
                end,
                desc = "Neotest: Summary Toggle",
            },
            {
                "<leader>tn",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest jump prev")
                    end)
                end,
                desc = "Neotest: Jump Prev",
            },
            {
                "<leader>tN",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest jump next")
                    end)
                end,
                desc = "Neotest: Jump Next",
            },
            {
                "<leader>ta",
                function()
                    wrap_neotest_flatten_nest(function()
                        vim.cmd("Neotest attach")
                    end)
                end,
                desc = "Neotest: Attach",
            },
        },
        config = function()
            vim.api.nvim_create_autocmd("BufWinEnter", {
                pattern = "*Neotest Summary*",
                callback = function(args)
                    local buf = args.buf
                    for _, winnr in ipairs(vim.fn.win_findbuf(buf)) do
                        local wo = vim.wo[winnr]
                        wo.wrap = false
                        wo.statuscolumn = ""
                        wo.foldcolumn = "0"
                        wo.number = false
                        wo.signcolumn = "no"
                    end
                end,
            })
            require("neotest").setup({
                diagnostic = {
                    enable = true,
                    severity = 1,
                },
                status = {
                    virtual_text = true,
                },
                adapters = {
                    require("neotest-plenary"),
                    require("neotest-go"),
                    require("rustaceanvim.neotest"),
                },
            })
        end,
    },
}
