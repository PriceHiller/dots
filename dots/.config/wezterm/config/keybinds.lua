local wezterm = require("wezterm")

local adjust_pane_size_amount = 5

return {
    disable_default_key_bindings = true,
    leader = { key = "a", mods = "CTRL", timeout_milliseconds = 100000 },
    key_tables = {
        -- NOTE: Pane Resizing Submap
        resize_pane = {
            { key = "LeftArrow", action = wezterm.action.AdjustPaneSize({ "Left", adjust_pane_size_amount }) },
            { key = "h", action = wezterm.action.AdjustPaneSize({ "Left", adjust_pane_size_amount }) },
            { key = "RightArrow", action = wezterm.action.AdjustPaneSize({ "Right", adjust_pane_size_amount }) },
            { key = "l", action = wezterm.action.AdjustPaneSize({ "Right", adjust_pane_size_amount }) },
            { key = "UpArrow", action = wezterm.action.AdjustPaneSize({ "Up", adjust_pane_size_amount }) },
            { key = "k", action = wezterm.action.AdjustPaneSize({ "Up", adjust_pane_size_amount }) },
            { key = "DownArrow", action = wezterm.action.AdjustPaneSize({ "Down", adjust_pane_size_amount }) },
            { key = "j", action = wezterm.action.AdjustPaneSize({ "Down", adjust_pane_size_amount }) },

            -- Cancel the mode by pressing escape
            { key = "Escape", action = "PopKeyTable" },
        },

        -- NOTE: Pane Rotate Position Submap
        rotate_panes = {
            { key = "h", action = wezterm.action.RotatePanes("CounterClockwise") },
            { key = "LeftArrow", action = wezterm.action.RotatePanes("CounterClockwise") },
            { key = "l", action = wezterm.action.RotatePanes("Clockwise") },
            { key = "RightArrow", action = wezterm.action.RotatePanes("Clockwise") },
            { key = "Escape", action = "PopKeyTable" },
        },
    },
    keys = {
        {
            key = "r",
            mods = "SUPER",
            action = "ReloadConfiguration",
        },
        {
            key = "z",
            mods = "SUPER",
            action = wezterm.action({
                ActivateTabRelative = -1,
            }),
        },
        {
            key = "x",
            mods = "SUPER",
            action = wezterm.action({
                ActivateTabRelative = 1,
            }),
        },
        {
            key = "t",
            mods = "SUPER",
            action = wezterm.action({
                SpawnTab = "CurrentPaneDomain",
            }),
        },
        {
            key = "w",
            mods = "ALT",
            action = wezterm.action({
                CloseCurrentPane = { confirm = false },
            }),
        },
        {
            key = "w",
            mods = "SUPER",
            action = wezterm.action({
                CloseCurrentTab = { confirm = false },
            }),
        },
        { key = "Copy", action = wezterm.action({ CopyTo = "Clipboard" }) },
        { key = "Paste", action = wezterm.action({ PasteFrom = "Clipboard" }) },
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
        { key = "0", mods = "CTRL", action = "ResetFontSize" },

        -- NOTE: Leader dependent binds
        { key = "h", mods = "LEADER", action = wezterm.action({ EmitEvent = "trigger-nvim-with-scrollback" }) },
        { key = "f", mods = "LEADER", action = wezterm.action.ToggleFullScreen },

        -- NOTE: Quick bindings for in terminal use
        { key = "w", mods = "LEADER", action = { SendString = "wgrep\x0D" } },
        { key = "t", mods = "LEADER", action = { SendString = "fd --color=always | fzf\x0D" } },

        -- NOTE: Copy & Paste
        { key = "v", mods = "SUPER", action = wezterm.action.PasteFrom("Clipboard") },
        { key = "c", mods = "SUPER", action = wezterm.action.CopyTo("ClipboardAndPrimarySelection") },

        -- NOTE: Debugging
        { key = "d", mods = "LEADER", action = wezterm.action.ShowDebugOverlay },

        -- NOTE: Show Commands
        { key = "a", mods = "LEADER", action = wezterm.action.ActivateCommandPalette },
        -- NOTE: Pane Resizing Submap Call
        {
            key = "r",
            mods = "LEADER",
            action = wezterm.action.ActivateKeyTable({
                name = "resize_pane",
                one_shot = false,
            }),
        },
        -- NOTE: Pane Rotate Submap Call
        {
            key = "z",
            mods = "LEADER",
            action = wezterm.action.ActivateKeyTable({
                name = "rotate_panes",
                one_shot = false,
            }),
        },
    },
}
