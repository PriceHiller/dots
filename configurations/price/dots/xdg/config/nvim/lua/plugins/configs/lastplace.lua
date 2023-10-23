return {
    {
        "ethanholz/nvim-lastplace",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit", "fugitive" },
            lastplace_open_folds = true,
        },
    },
}
