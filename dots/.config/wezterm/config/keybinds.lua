local wezterm = require("wezterm")

return {
    disable_default_key_bindings = true,
    leader = { key = "a", mods = "CTRL", timeout_milliseconds = 100000 },
    keys = {
        { key = "r", mods = "SUPER", action = "ReloadConfiguration" },
        { key = "z", mods = "ALT", action = wezterm.action({ ActivateTabRelative = -1 }) },
        { key = "x", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
        { key = "t", mods = "SUPER", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
        { key = "w", mods = "ALT", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
        { key = "w", mods = "SUPER", action = wezterm.action({ CloseCurrentTab = { confirm = false } }) },
        { key = "c", mods = "SUPER", action = wezterm.action({ CopyTo = "Clipboard" }) },
        { key = "v", mods = "SUPER", action = wezterm.action({ PasteFrom = "Clipboard" }) },
        -- NOTE: Pane Splitting
        {
            key = "RightArrow",
            mods = "SHIFT",
            action = wezterm.action({ SplitPane = { direction = "Right" } }),
        },
        {
            key = "LeftArrow",
            mods = "SHIFT",
            action = wezterm.action({ SplitPane = { direction = "Left" } }),
        },
        {
            key = "UpArrow",
            mods = "SHIFT",
            action = wezterm.action({ SplitPane = { direction = "Up" } }),
        },
        {
            key = "DownArrow",
            mods = "SHIFT",
            action = wezterm.action({ SplitPane = { direction = "Down" } }),
        },
        -- NOTE: Pane Selecting
        {
            key = "RightArrow",
            mods = "CTRL",
            action = wezterm.action({ ActivatePaneDirection = "Right" }),
        },
        {
            key = "LeftArrow",
            mods = "CTRL",
            action = wezterm.action({ ActivatePaneDirection = "Left" }),
        },
        {
            key = "UpArrow",
            mods = "CTRL",
            action = wezterm.action({ ActivatePaneDirection = "Up" }),
        },
        {
            key = "DownArrow",
            mods = "CTRL",
            action = wezterm.action({ ActivatePaneDirection = "Down" }),
        },
        { key = "=", mods = "CTRL", action = "IncreaseFontSize" },
        { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
        { key = "0", mods = "CTRL", action = "ResetFontAndWindowSize" },

        -- NOTE: Leader dependent binds
        { key = "h", mods = "LEADER", action = wezterm.action({ EmitEvent = "trigger-nvim-with-scrollback" }) },
        { key = "f", mods = "LEADER", action = wezterm.action.ToggleFullScreen },

        -- NOTE: Quick bindings for in terminal use
        { key = "w", mods = "LEADER", action = { SendString = "wgrep\x0D" } },
        { key = "t", mods = "LEADER", action = { SendString = "fd --color=always | fzf\x0D" } },

        -- NOTE: Copy & Paste
        { key = "v", mods = "SUPER", action = wezterm.action.PasteFrom("PrimarySelection") },
        { key = "c", mods = "SUPER", action = wezterm.action.CopyTo("ClipboardAndPrimarySelection") },
    },
    key_tables = {},
}
