require("stabilize").setup({
    -- stabilize window even when current cursor position will be hidden behind new window
    force = true,
    -- set context mark to register on force event which can be jumped to with '<forcemark>
    forcemark = nil,
    -- do not manage windows matching these file/buftypes
    ignore = {
        filetype = { "packer", "Dashboard", "Trouble", "TelescopePrompt" },
        buftype = {
            "packer",
            "Dashboard",
            "terminal",
            "quickfix",
            "loclist",
            "LspInstall",
        },
    },
    -- comma-separated list of autocmds that wil trigger the plugins window restore function
    nested = nil,
})
