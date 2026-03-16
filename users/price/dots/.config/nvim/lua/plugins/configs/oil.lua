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
                watch_for_changes = true,
                view_options = {
                    show_hidden = true,
                },
                keymaps = {
                    ["<BS>"] = { "actions.parent", mode = "n" },
                },
                columns = {
                    "permissions",
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
