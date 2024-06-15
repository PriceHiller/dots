return {
    {
        "RRethy/vim-illuminate",
        event = { "CursorHold", "BufReadPre", "BufNewFile" },
        config = function()
            require("illuminate").configure({ large_file_cutoff = 10000 })
        end,
    },
}
