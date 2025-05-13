return {
    {
        "stevearc/oil.nvim",
        cmd = {
            "Oil",
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                default_file_explorer = false,
                columns = {
                    "icon",
                    "permissions",
                    "size",
                    "mtime",
                },
                keymaps = {
                    ["<BS>"] = { "actions.parent", mode = "n" },
                },
            })
        end,
        keys = {
            {
                "<leader>no",
                function()
                    local oil = require("oil")
                    oil.toggle_float(vim.uv.cwd())
                end,
                desc = "Oil: Open",
            },
        },
    },
}
