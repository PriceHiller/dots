return {
    {
        "miversen33/netman.nvim",
        lazy = true,
        event = "CmdlineEnter",
        cmd = {
            "NmloadProvider",
            "Nmlogs",
            "Nmdelete",
            "Nmread",
            "Nmwrite",
        },
        config = function()
            require("netman")
        end,
    },
}
