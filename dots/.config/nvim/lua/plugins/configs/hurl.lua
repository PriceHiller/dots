return {
    {
        "jellydn/hurl.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        ft = "hurl",
        opts = {
            debug = false,
            mode = "split",
            formatters = {
                json = { 'jq' },
                html = {
                    'prettier',
                    '--parser',
                    'html',
                },
            },
        },
        keys = {
            { "<leader>fr",  "<cmd>HurlRunner<CR>",        desc = "Hurl: Runner" },
            { "<leader>fa",  "<cmd>HurlRunnerAt<CR>",      desc = "Hurl: Run Api request" },
            { "<leader>fe", "<cmd>HurlRunnerToEntry<CR>", desc = "Hurl: Run Api request to entry" },
            { "<leader>fm", "<cmd>HurlToggleMode<CR>",    desc = "Hurl: Toggle Mode" },
            { "<leader>rv", "<cmd>HurlVerbose<CR>",       desc = "Hurl: Run Api in verbose mode" },
            { "<leader>fr",  ":HurlRunner<CR>",            desc = "Hurl: Runner",             mode = "v" },
        },
    }
}
