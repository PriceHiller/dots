--- Fancy wrapper for deleting the current buffer based on the window type, tab statuses, etc.
---
--- Kinda cursed... definitely better ways of doing this, but by god its my trash! Mfers ask "You
--- really live like this?" and the answer is YES! Yes I do.
---@param opts number|snacks.bufdelete.Opts?
local bwdelete = function(opts)
    opts = opts or {}
    opts.buf = opts.buf or vim.api.nvim_get_current_buf()

    local nuke = false

    if vim.fn.win_gettype() ~= '' and not vim.bo[opts.buf].modified then
        opts.force = true
        nuke = true
    end

    if
        nuke
        or (
            #vim.api.nvim_list_tabpages() > 1
            and #vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage()) == 1
        )
    then
        local cmd = opts.wipe and vim.cmd.bwipeout or vim.cmd.bdelete
        cmd({ args = { opts.buf }, bang = opts.force })
    else
        require("snacks").bufdelete.delete(opts)
    end
end

--- Set a mapping to quickly close the current buffer
---@param bufnr integer A buffer id
local map_quick_close = function(bufnr)
    vim.iter({
        "q/",
        "q?",
        "q:",
    }):each(function(lhs)
        pcall(vim.keymap.del, "n", lhs)
    end)
    vim.keymap.set("n", "q", function()
        bwdelete({ buf = bufnr, force = true })
    end, { silent = true, buffer = bufnr, desc = "Close Terminal Buffer" })
end

vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
    callback = function(args)
        if args.event == "TermOpen" then
            map_quick_close(args.buf)
            return
        end
        local bo = vim.bo[args.buf]
        if vim.list_contains({ "nofile", "terminal", "nowrite", "help" }, bo.buftype) then
            map_quick_close(args.buf)
            return
        end
    end,
})

return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
            {
                "<A-x>",
                bwdelete,
                desc = "Close Buffer",
                mode = { "", "!", "v" },
            },

            {
                "<A-x>",
                function()
                    bwdelete({ force = true })
                end,
                desc = "Close Buffer",
                mode = { "t" },
            },
            {
                "<leader>nd",
                function()
                    require("snacks").notifier.hide()
                end,
                desc = "Notifications: Dismiss",
            },
            {
                "<leader>nv",
                function()
                    require("snacks").notifier.show_history({
                        sort = { "added" },
                    })
                end,
                desc = "Notifications: Search",
            },
        },
        config = function()
            local snacks = require("snacks")
            snacks.setup({
                bigfile = { enabled = true },
                debug = { enabled = true },
                notifier = {
                    enabled = true,
                    style = "compact",
                    margin = { top = 1 },
                },
                words = { enabled = true },
                statuscolumn = { enabled = false },
            })
            snacks.config.styles["notification.history"] = {
                title = { { "Notification History", "@markup.heading.4" } },
                border = { " " },
            }
            _G.bt = snacks.debug.backtrace
            _G.dd = snacks.debug.inspect
            vim.print = snacks.debug.inspect
        end,
    },
}
