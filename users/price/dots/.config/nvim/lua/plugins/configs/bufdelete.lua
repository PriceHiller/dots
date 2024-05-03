vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(args)
        vim.keymap.set("n", "q", function()
            require("bufdelete").bufdelete(0, true)
        end, { silent = true, buffer = args.buf, remap = true, desc = "Close Terminal Buffer" })
    end,
})

return {
    {
        "famiu/bufdelete.nvim",
        cmd = "Bdelete",
        keys = {
            { "<A-x>", "<cmd>Bdelete<cr>", desc = "Close Buffer" },
        },
    },
}
