return {
    {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup({
                max_line_len = vim.opt.textwidth,
                lsp_keymaps = false,
                dap_debug_keymap = false,
                lsp_codelens = false,
                icons = false,
                run_in_floaterm = true,
                trouble = true,
                luasnip = true
            })
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    },
}
