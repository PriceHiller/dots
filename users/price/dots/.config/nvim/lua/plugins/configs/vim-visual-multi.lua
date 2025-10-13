return {
    {
        "mg979/vim-visual-multi",
        event = "VeryLazy",
        init = function()
            vim.g.VM_mouse_mappings = 1
            vim.g.VM_show_warnings = 0
            vim.g.VM_maps = {
                ["I BS"] = "",
                ["Goto Next"] = "]v",
                ["Goto Prev"] = "[v",
                ["I CtrlB"] = "<M-b>",
                ["I CtrlF"] = "<M-f>",
                ["I Return"] = "<S-CR>",
                ["I Down Arrow"] = "",
                ["I Up Arrow"] = "",
            }
        end,
        config = function()
            vim.cmd.VMTheme("codedark")
        end,
    },
}
