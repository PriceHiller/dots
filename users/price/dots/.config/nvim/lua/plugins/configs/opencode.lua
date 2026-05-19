return {
    {
        "sudo-tee/opencode.nvim",
        config = function()
            -- Default configuration with all available options
            require("opencode").setup({
                preferred_picker = "snacks", -- 'telescope', 'fzf', 'mini.pick', 'snacks', 'select', if nil, it will use the best available picker. Note mini.pick does not support multiple selections
                preferred_completion = "blink", -- 'blink', 'nvim-cmp','vim_complete' if nil, it will use the best available completion
                default_global_keymaps = true, -- If false, disables all default global keymaps
                default_mode = "plan", -- 'build' or 'plan' or any custom configured. @see [OpenCode Agents](https://opencode.ai/docs/modes/)
                keymap_prefix = "<leader>z", -- Default keymap prefix for global keymaps change to your preferred prefix and it will be applied to all keymaps starting with <leader>o
                opencode_executable = "opencode", -- Name of your opencode binary
                ui = {
                    output = {
                        tools = {
                            use_folds = false
                        }
                    },
                },
            })
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "saghen/blink.cmp",
            "folke/snacks.nvim",
        },
    },
}
