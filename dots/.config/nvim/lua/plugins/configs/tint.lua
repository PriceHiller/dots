return {
    {
        "levouh/tint.nvim",
        event = "WinLeave",
        opts = {
            highlight_ignore_patterns = {
                "WinSeparator",
            },
            window_ignore_function = function(winid)
                local bufid = vim.api.nvim_win_get_buf(winid)

                local ignoredFiletypes = { "DiffviewFiles", "DiffviewFileHistory", "neo-tree" }
                local ignoredBuftypes = { "terminal" }

                local isDiff = vim.api.nvim_win_get_option(winid, "diff")
                local isFloating = vim.api.nvim_win_get_config(winid).relative ~= ""
                local isIgnoredBuftype =
                    vim.tbl_contains(ignoredBuftypes, vim.api.nvim_buf_get_option(bufid, "buftype"))
                local isIgnoredFiletype =
                    vim.tbl_contains(ignoredFiletypes, vim.api.nvim_buf_get_option(bufid, "filetype"))

                return isDiff or isFloating or isIgnoredBuftype or isIgnoredFiletype
            end,
            tint = -10,
            saturation = 0.85,
        },
    },
}
