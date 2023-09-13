return {
    {
        "akinsho/toggleterm.nvim",
        keys = {
            {
                "<leader><leader>",
                function()
                    local mode = vim.fn.mode(1)
                    local curr_buffer = vim.api.nvim_buf_get_name(0)
                    local toggleterm_match = function(buf_name)
                        return buf_name:find("toggleterm#", 1, true)
                    end
                    if toggleterm_match(curr_buffer) then
                        -- Try to exit with toggleterm
                        vim.cmd.ToggleTerm()

                        -- We didn't successfully exit, use `q` to do so.
                        if toggleterm_match(vim.api.nvim_buf_get_name(0)) then
                            vim.cmd(":q")
                        end
                    else
                        vim.cmd.ToggleTerm()
                    end
                end,
                desc = "ToggleTerm: Toggle",
            },
        },
        opts = {
            start_in_insert = false,
            direction = "float",
            autochdir = true,
            winbar = {
                enable = true,
                name_formatter = function(term) --  term: Terminal
                    return term.name
                end,
            },
        },
        cmd = {
            "ToggleTerm",
            "ToggleTermSetName",
            "ToggleTermToggleAll",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualLines",
            "ToggleTermSendVisualSelection",
        },
    },
}
