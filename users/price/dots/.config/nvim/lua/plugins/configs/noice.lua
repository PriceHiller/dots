return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        keys = {
            { "<D-A-m>", "<cmd>Noice all<CR>", desc = "Noice: Show All Messages" },
        },
        config = function()
            require("noice").setup({
                lsp = {
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                    },
                },
                presets = {
                    long_message_to_split = true,
                    command_palette = true,
                },
                views = {
                    cmdline_popup = {
                        border = {
                            style = "none",
                        },
                        position = {
                            row = "99%",
                            col = "0%",
                        },
                    },
                },
                routes = {
                    {
                        filter = { event = "msg_show", find = "Hop .*:%s*" },
                        opts = { skip = true },
                    },
                    -- Ignore `written` message
                    {
                        filter = { event = "msg_show", find = '^".*" .*%d*L, %d*B written$' },
                        opts = { skip = true },
                    },
                    -- Ignore `undo` message
                    {
                        filter = { event = "msg_show", find = "^%d+ .*; before #%d+ .*$" },
                        opts = { skip = true },
                    },
                    -- Ignore `redo` message
                    {
                        filter = { event = "msg_show", find = "^%d+ .*; after #%d+ .*$" },
                        opts = { skip = true },
                    },
                    {
                        view = "split",
                        filter = { event = "msg_show", min_height = 20 },
                    },
                },
            })

            ---Fold expression for Noice buffers based on NoiceFormatEvent extmarks.
            ---@return string foldlevel Vim fold level (">1", "=", or "0")
            function _G.NoiceFoldExpr()
                local bufnr = vim.api.nvim_get_current_buf()
                local lnum = vim.v.lnum
                local ns_id = vim.api.nvim_get_namespaces()["noice"]
                if not ns_id then
                    return "0"
                end

                local extmarks = vim.api.nvim_buf_get_extmarks(
                    bufnr,
                    ns_id,
                    { lnum - 1, 0 },
                    { lnum - 1, -1 },
                    { details = true }
                )

                for _, mark in ipairs(extmarks) do
                    local details = mark[4]
                    if details and details.hl_group == "NoiceFormatEvent" then
                        return ">1"
                    end
                end
                return "="
            end

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "noice",
                callback = function(args)
                    local buf = args.buf
                    vim.schedule(function()
                        for _, winnr in ipairs(vim.fn.win_findbuf(buf)) do
                            local wo = vim.wo[winnr]
                            wo.foldmethod = "expr"
                            wo.foldexpr = "v:lua.NoiceFoldExpr()"
                            wo.foldenable = true
                            wo.foldlevel = 0
                        end
                    end)
                end,
                desc = "Apply custom NoiceFoldExpr to noice message buffers",
            })

            vim.opt.cmdheight = 0
        end,
    },
}
