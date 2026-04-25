return {
    {
        "olimorris/codecompanion.nvim",
        cmd = {
            "CodeCompanion",
            "CodeCompanionActions",
            "CodeCompanionChat",
            "CodeCompanionCLI",
            "CodeCompanionCmd",
        },
        keys = {
            { "<leader>z", desc = "> Code Companion" },
            { "<leader>zz", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Code Companion: Chat Toggle" },
            { "<leader>za", "<cmd>CodeCompanionActions<CR>", desc = "Code Companion: Actions" },
            { "<leader>zc", "<cmd>CodeCompanion<CR>", desc = "Code Companion" },
        },
        config = function()
            require("codecompanion").setup({
                display = {
                    diff = {
                        enabled = true,
                    },
                },
                opts = {
                    triggers = {
                        acp_slash_commands = "!",
                    },
                },
                interactions = {
                    chat = {
                        adapter = {
                            name = "opencode",
                            model = "openrouter/google/gemini-3.1-pro-preview",
                        },
                        ---@param ctx CodeCompanion.SystemPrompt.Context
                        ---@return string
                        system_prompt = function(ctx)
                            return table.concat({
                                ctx.default_system_prompt,
                                "",
                                [[-----]],
                                "Additional context",
                                vim.trim([[
# General

Do not be overly obsequious.

# Math

All input is written in Typst's math format.
]]),
                            }, "\n")
                        end,
                    },
                    cli = {
                        agent = "opencode",
                    },
                    inline = {
                        adapter = {
                            name = "opencode",
                            model = "openrouter/google/gemini-3-pro-preview",
                        },
                    },
                    cmd = {
                        adapter = "opencode",
                    },
                    background = {
                        adapter = {
                            name = "opencode",
                            model = "openrouter/google/gemini-3-flash-preview",
                        },
                    },
                },
            })
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
}
