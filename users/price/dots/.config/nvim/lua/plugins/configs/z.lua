local utils = require("utils.funcs")
return {
    {
        "PriceHiller/z.nvim",
        cmd = { "Z" },
        init = function()
            utils.alias_cmd("z", "Z")
        end,
        config = function()
            require("z").setup({
                z_cmd = function()
                    return { "zoxide", "query", "--exclude", vim.fn.getcwd() }
                end,
                z_comp_cmd = function()
                    return { "zoxide", "query", "--list", "--exclude", vim.fn.getcwd() }
                end,
                z_dir_changed_cmd = { "zoxide", "add" },
            })
        end,
    },
}
