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
            { "<leader>k", desc = "> Neotest" },
            { "<leader>kr", "<cmd>Neotest run<CR>", desc = "Neotest: Run Test" },
            { "<leader>kf", "<cmd>Neotest run file<CR>", desc = "Neotest: Run Test(s) in File" },
            { "<leader>kl", "<cmd>Neotest run last<CR>", desc = "Neotest: Run Last Test(s)" },
            { "<leader>kp", "<cmd>Neotest output-panel<CR>", desc = "Neotest: Output Panel" },
            {
                "<leader>ko",
                function()
                    local neotest = require("neotest")
                    neotest.output.open({ enter = true })
                end,
                desc = "Neotest: Output",
            },
            { "<leader>kk", "<cmd>Neotest summary toggle<CR>", desc = "Neotest: Summary Toggle" },
            { "<leader>kn", "<cmd>Neotest jump prev<CR>", desc = "Neotest: Jump Prev" },
            { "<leader>kN", "<cmd>Neotest jump next<CR>", desc = "Neotest: Jump Next" },
            { "<leader>ka", "<cmd>Neotest attach<CR>", desc = "Neotest: Attach" },
        },
        opts = function()
            return {
                diagnostic = {
                    enable = true,
                    severity = 1,
                },
                discovery = {
                    concurrent = 4,
                },
                status = {
                    virtual_text = true,
                },
                adapters = {
                    require("neotest-plenary"),
                    require("neotest-go"),
                    require("rustaceanvim.neotest"),
                },
            }
        end,
    },
}
