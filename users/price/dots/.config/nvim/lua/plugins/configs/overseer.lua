return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerSaveBundle",
            "OverseerLoadBundle",
            "OverseerDeleteBundle",
            "OverseerRunCmd",
            "OverseerRun",
            "OverseerInfo",
            "OverseerBuild",
            "OverseerQuickAction",
            "OverseerTaskAction",
            "OverseerClearCache",
        },
        keys = {
            { "<leader>r", desc = "Overseer" },
            { "<leader>rs", "<cmd>OverseerRun<CR>", desc = "Overseer: Run" },
            { "<leader>rr", "<cmd>OverseerToggle<CR>", desc = "Overseer: Toggle" },
        },
        config = function()
            local overseer = require("overseer")
            overseer.setup()
            local tempname_caches = {}

            --- Get a temp file bound to the bufnr
            local function tempname()
                local bufnr = vim.api.nvim_get_current_buf()
                if not tempname_caches[bufnr] then
                    tempname_caches[bufnr] = vim.fn.tempname()
                end
                return tempname_caches[bufnr]
            end
            overseer.register_template(
                ---@type overseer.TemplateDefinition
                {
                    name = "Watch Typst",
                    desc = "Run `typst watch` and view the PDF",
                    ---@return overseer.TaskDefinition
                    builder = function(_)
                        return {
                            cmd = {
                                "typst",
                                "watch",
                                "--open=xdg-open",
                                vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
                                tempname() .. ".pdf",
                            },
                        }
                    end,
                    condition = {
                        filetype = "typst",
                    },
                }
            )
        end,
    },
}
