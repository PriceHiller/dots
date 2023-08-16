return {
    {
        "brenoprata10/nvim-highlight-colors",
        event = { "BufReadPre", "BufNewFile" },
        cmd = {
            "HighlightColorsOn",
            "HighlightColorsOff",
            "HighlightColorsToggle",
        },
        config = true
    },
}
