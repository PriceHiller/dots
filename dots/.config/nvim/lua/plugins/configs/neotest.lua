return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-go",
            "mrcjkb/rustaceanvim",
            "nvim-neotest/neotest-plenary"
        },
        keys = {
            { "<localleader>n",          desc = "> Neotest" },
            { "<localleader>nrr", "<cmd>Neotest run<CR>",            desc = "Neotest: Run Test" },
            { "<localleader>nrl", "<cmd>Neotest run file<CR>",       desc = "Neotest: Run Tests in File" },
            { "<localleader>nrl", "<cmd>Neotest run last<CR>",       desc = "Neotest: Run Last Tests" },
            { "<localleader>np",  "<cmd>Neotest output-panel<CR>",   desc = "Neotest: Output Panel" },
            { "<localleader>no",  "<cmd>Neotest output<CR>",         desc = "Neotest: Output" },
            { "<localleader>nn",  "<cmd>Neotest summary toggle<CR>", desc = "Neotest: Summary Toggle" },
            { "<localleader>nk",  "<cmd>Neotest jump prev<CR>",      desc = "Neotest: Jump Prev" },
            { "<localleader>nj",  "<cmd>Neotest jump next<CR>",      desc = "Neotest: Jump Next" },
            { "<localleader>na",  "<cmd>Neotest attach<CR>",         desc = "Neotest: Attach" },
        },
        opts = function()
            return {
                diagnostic = {
                    enable   = true,
                    severity = 1
                },
                discovery = {
                    concurrent = 4
                },
                status = {
                    virtual_text = true
                },
                adapters = {
                    require("neotest-plenary"),
                    require("neotest-go"),
                    require('rustaceanvim.neotest')
                },
            }
        end,
    },
}
