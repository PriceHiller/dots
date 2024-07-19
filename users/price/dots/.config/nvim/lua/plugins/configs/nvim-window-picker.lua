return {
    {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        opts = {
            hint = "floating-big-letter",
            ---@param window_ids integer[]
            filter_func = function(window_ids)
                local cur_win = vim.api.nvim_get_current_win()
                return vim.iter(window_ids)
                    :filter(function(win_id)
                        local win_type = vim.fn.win_gettype(win_id)
                        return not vim.list_contains({
                            "preview",
                            "unknown",
                            "popup",
                            "command",
                        }, win_type) and win_id ~= cur_win
                    end)
                    :totable()
            end,
            bo = {
                buftype = {},
            },
            show_prompt = false,
        },
        keys = {
            {
                "<leader>w",
                function()
                    local win_id = require("window-picker").pick_window() or vim.api.nvim_get_current_win()
                    vim.api.nvim_set_current_win(win_id)
                end,
                desc = "Window: Select",
            },
        },
    },
}
