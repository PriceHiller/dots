return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "fredrikaverpil/neotest-golang",
            "mrcjkb/rustaceanvim",
            "nvim-neotest/neotest-plenary",
        },
        keys = {
            { "<leader>t", desc = "> Neotest" },
            { "<leader>tr", "<cmd>Neotest run<CR>", desc = "Neotest: Run Test" },
            { "<leader>tf", "<cmd>Neotest run file<CR>", desc = "Neotest: Run Test(s) in File" },
            { "<leader>tl", "<cmd>Neotest run last<CR>", desc = "Neotest: Run Last Test(s)" },
            { "<leader>tp", "<cmd>Neotest output-panel<CR>", desc = "Neotest: Output Panel" },
            {
                "<leader>to",
                function()
                    local neotest = require("neotest")
                    neotest.output.open({ enter = true })
                end,
                desc = "Neotest: Output",
            },
            { "<leader>tk", "<cmd>Neotest summary toggle<CR>", desc = "Neotest: Summary Toggle" },
            { "<leader>tn", "<cmd>Neotest jump prev<CR>", desc = "Neotest: Jump Prev" },
            { "<leader>tN", "<cmd>Neotest jump next<CR>", desc = "Neotest: Jump Next" },
            { "<leader>ta", "<cmd>Neotest attach<CR>", desc = "Neotest: Attach" },
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
                    require("neotest-golang"),
                    require("rustaceanvim.neotest"),
                },
            })
        end,
    },
}
