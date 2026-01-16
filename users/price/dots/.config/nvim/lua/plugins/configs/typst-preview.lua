return {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    config = function()
        local typst_preview = require("typst-preview")
        local dark_mode = true
        local function get_invert_setting()
            return dark_mode and "always" or "never"
        end

        vim.api.nvim_create_user_command("TypstPreviewToggleDarkMode", function()
            vim.cmd.TypstPreviewStop()
            dark_mode = not dark_mode

            local new_invert_setting = get_invert_setting()

            -- Get existing config and override just the invert_colors setting
            local config = require("typst-preview.config")
            local new_config = vim.tbl_deep_extend("force", config, {
                invert_colors = new_invert_setting,
            })

            typst_preview.setup(new_config)

            vim.defer_fn(function()
                vim.cmd.TypstPreviewToggle()
            end, 200)

            local mode_text = get_invert_setting()
            vim.notify("Typst preview: Dark mode `" .. mode_text .. "`", vim.log.levels.INFO)
        end, {
            desc = "Toggle Typst Preview Dark Mode",
        })
        typst_preview.setup({
            invert_colors = get_invert_setting(),
        })
    end,
}
