return {
    {
        "RaafatTurki/hex.nvim",
        opts = {
            -- Make it explicit, auto detection is cool and all, but annoying for my use case
            is_buf_binary_pre_read = function()
                return false
            end,
            is_buf_binary_post_read = function()
                return false
            end,
        },
        cmd = {
            "HexDump",
            "HexAssemble",
            "HexToggle",
        },
    },
}
