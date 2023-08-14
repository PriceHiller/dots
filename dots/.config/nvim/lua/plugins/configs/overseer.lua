return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerRun",
            "OverseerInfo",
            "OverseerOpen",
            "OverseerBuild",
            "OverseerClose",
            "OverseerRunCmd",
            "OverseerToggle",
            "OverseerClearCache",
            "OverseerLoadBundle",
            "OverseerSaveBundle",
            "OverseerTaskAction",
            "OverseerQuickAction",
            "OverseerDeleteBundle",
        },
        keys = {
            { "<leader>or", desc = "> Overseer" },
            { "<leader>or", vim.cmd.OverseerRun, desc = "Overseer: Run" },
            { "<leader>ot", vim.cmd.OverseerToggle, desc = "Overseer: Toggle" },
        },
        opts = {},
    },
}
