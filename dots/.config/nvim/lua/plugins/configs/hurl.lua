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
    }
}
