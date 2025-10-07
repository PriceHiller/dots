vim.api.nvim_create_autocmd({ "User" }, {
    group = vim.api.nvim_create_augroup("cmdbuf_setting", {}),
    pattern = { "CmdbufNew" },
    callback = function()
        vim.bo.bufhidden = "wipe"
        vim.keymap.set("n", "q", [[<Cmd>quit<CR>]], { nowait = true, buffer = true })
        vim.keymap.set("n", "dd", require("cmdbuf").delete, { buffer = true })
        vim.keymap.set({ "n", "i" }, "<C-c>", function()
            return require("cmdbuf").cmdline_expr()
        end, { buffer = true, expr = true })

        vim.keymap.set("n", "dd", require("cmdbuf").delete, { buffer = true })
    end,
})

return {
    {
        "notomo/cmdbuf.nvim",
        keys = {
            {
                "q:",
                function()
                    require("cmdbuf").split_open(vim.o.cmdwinheight)
                end,
            },
            {
                "q/",
                function()
                    require("cmdbuf").split_open(vim.o.cmdwinheight, { type = "vim/search/forward" })
                end,
            },
            {
                "q?",
                function()
                    require("cmdbuf").split_open(vim.o.cmdwinheight, { type = "vim/search/backward" })
                end,
            },
            {
                "q,",
                function()
                    require("cmdbuf").split_open(vim.o.cmdwinheight, { type = "lua/cmd" })
                end,
            },
            {
                mode = "c",
                "<C-f>",
                function()
                    require("cmdbuf").split_open(
                        vim.o.cmdwinheight,
                        { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos() }
                    )
                    vim.api.nvim_feedkeys(vim.keycode("<C-c>"), "n", true)
                end,
            },
            {
                mode = "c",
                "<C-l>",
                function()
                    require("cmdbuf").split_open(
                        vim.o.cmdwinheight,
                        { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos(), type = "lua/cmd" }
                    )
                    vim.api.nvim_feedkeys(vim.keycode("<C-c>"), "n", true)
                end,
            },
        },
    },
}
