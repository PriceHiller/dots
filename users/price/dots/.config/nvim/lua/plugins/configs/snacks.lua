--- Fancy wrapper for deleting the current buffer based on the window type, tab statuses, etc.
---
--- Kinda cursed... definitely better ways of doing this, but by god its my trash! Mfers ask "You
--- really live like this?" and the answer is YES! Yes I do.
---@param opts number|snacks.bufdelete.Opts?
local bwdelete = function(opts)
    opts = opts or {}
    opts.buf = opts.buf or vim.api.nvim_get_current_buf()

    local nuke = false

    if vim.fn.win_gettype() ~= "" and not vim.bo[opts.buf].modified then
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
        vim.cmd.bdelete({ args = { bufnr }, bang = true })
    end, { silent = true, buffer = bufnr, desc = "Quick Close Buffer" })
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
            {
                "<leader>f",
                desc = "> Picker",
            },
            {
                "<leader>j",
                function()
                    require("snacks").picker.buffers()
                end,
                desc = "Pick: Buffers",
            },
            {
                "<leader>fb",
                function()
                    require("snacks").picker.buffers()
                end,
                desc = "Pick: Buffers",
            },
            {
                "<leader>ff",
                function()
                    require("snacks").picker.files()
                end,
                desc = "Pick: Files",
            },
            {
                "<leader>fw",
                function()
                    require("snacks").picker.grep()
                end,
                desc = "Pick: Grep Words",
            },
            {
                "<leader>fr",
                function()
                    require("snacks").picker.recent()
                end,
                desc = "Pick: Recent Files",
            },
            {
                "<leader>fk",
                function()
                    require("snacks").picker.resume()
                end,
                desc = "Pick: Resume",
            },
            {
                "<leader>fm",
                function()
                    require("snacks").picker.keymaps()
                end,
                desc = "Pick: Keymaps",
            },
            {
                "<leader>fh",
                function()
                    require("snacks").picker.command_history()
                end,
                desc = "Pick: Command History",
            },
            {
                "<leader>fH",
                function()
                    require("snacks").picker.highlights()
                end,
                desc = "Pick: Highlights",
            },
            {
                "<leader>fu",
                function()
                    require("snacks").picker.undo()
                end,
                desc = "Pick: Highlights",
            },
            {
                "<leader>fe",
                function()
                    require("snacks").picker.explorer()
                end,
                desc = "Pick: Explorer",
            },
        },
        config = function()
            local snacks = require("snacks")

            ---@class CustomSnacksPickersLayouts: snacks.picker.layouts
            snacks.setup({
                styles = {
                    ---@diagnostic disable-next-line: missing-fields
                    notification_history = {
                        title = "Notification History",
                        ---@diagnostic disable-next-line: assign-type-mismatch
                        border = { { " ", "INVALIDHIGHLIGHTHERE" } },
                    },
                },
                bigfile = { enabled = true },
                debug = { enabled = true },
                notifier = {
                    enabled = true,
                    style = "compact",
                    margin = { top = 1 },
                },
                words = { enabled = true },
                input = {
                    enabled = true,
                },
                statuscolumn = { enabled = false },
                explorer = {
                    replace_netrw = true,
                },
                picker = {
                    prompt = "  ",
                    ui_select = true,
                    layouts = {
                        default = {
                            layout = {
                                box = "horizontal",
                                width = 0.95,
                                min_width = 120,
                                height = 0.95,
                                {
                                    box = "vertical",
                                    border = "none",
                                    {
                                        win = "input",
                                        height = 1,
                                        title = "{source} {live}",
                                        title_pos = "center",
                                        border = {
                                            "",
                                            " ",
                                            "",
                                            "",
                                            "",
                                            " ",
                                            "",
                                            "",
                                        },
                                    },
                                    {
                                        border = {
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                            "",
                                        },
                                        win = "list",
                                    },
                                },
                                {
                                    win = "preview",
                                    border = {
                                        "",
                                        " ",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                    },
                                    width = 0.70,
                                },
                            },
                        },
                        vertical = {
                            layout = {
                                box = "vertical",
                                width = 0.90,
                                min_width = 80,
                                height = 0.98,
                                min_height = 30,
                                {
                                    win = "preview",
                                    height = 0.65,
                                    border = { "", " ", "", "", "", "", "", "" },
                                },
                                {
                                    win = "input",
                                    height = 1,
                                    title = "{source} {live}",
                                    title_pos = "center",
                                    border = { "", " ", "", "", "", " ", "", "" },
                                },
                                {
                                    win = "list",
                                    border = { "", " ", "", "", "", "", "", "" },
                                },
                            },
                        },
                        vscode = {
                            layout = {
                                row = 1,
                                width = 0.4,
                                min_width = 80,
                                height = 0.4,
                                border = "none",
                                box = "vertical",
                                {
                                    win = "input",
                                    height = 1,
                                    border = { "", " ", "", "", "", " ", "", "" },
                                    title = "{source} {live}",
                                    title_pos = "center",
                                },
                                {
                                    win = "list",
                                    border = "none",
                                },
                                {
                                    win = "preview",
                                    border = "none",
                                },
                            },
                        },
                        select = {
                            layout = {
                                width = 0.5,
                                min_width = 80,
                                height = 0.4,
                                min_height = 10,
                                box = "vertical",
                                {
                                    win = "input",
                                    height = 1,
                                    border = { "", " ", "", "", "", " ", "", "" },
                                    title = " Select ",
                                    title_pos = "center",
                                },
                                {
                                    win = "list",
                                    border = "none",
                                },
                                {
                                    win = "preview",
                                    height = 0.4,
                                    border = "top",
                                },
                            },
                        },
                    },
                    actions = {
                        select = function(picker)
                            picker.list:select()
                        end,
                        deselect_all = function(picker)
                            picker.list:set_selected({})
                        end,
                    },
                    win = {
                        list = {
                            keys = {
                                ["<S-Tab>"] = false,
                                ["<Tab>"] = { "select", mode = { "i", "n", "x" } },
                                ["<C-x>"] = { "deselect_all", mode = { "i", "n", "x" } },
                                ["q"] = { "close", mode = { "n", "x" } },
                            },
                        },
                    },
                    layout = {
                        cycle = true,
                        preset = function()
                            return vim.o.columns >= 120 and "default" or "vertical"
                        end,
                    },
                    formatters = {
                        file = {
                            filename_first = true,
                        },
                    },
                    sources = {
                        files = {
                            hidden = true,
                            ignored = true,
                        },
                        grep = {
                            hidden = true,
                            ignored = true,
                        },
                        explorer = {
                            include = { "*" },
                            git_status_open = true,
                            diagnostics_open = true,
                            actions = {
                                explorer_input_cancel = function(picker)
                                    picker:norm(function()
                                        picker:focus("list")
                                    end)
                                end,
                            },
                            win = {
                                input = {
                                    keys = {
                                        ["<ESC>"] = { "explorer_input_cancel", mode = { "n", "x" } },
                                    },
                                },
                            },
                            layout = {
                                layout = {
                                    backdrop = false,
                                    width = 40,
                                    min_width = 40,
                                    height = 0,
                                    position = "left",
                                    border = "none",
                                    box = "vertical",
                                    {
                                        win = "input",
                                        height = 1,
                                        border = "solid",
                                        title = "{title} {live} {flags}",
                                        title_pos = "center",
                                    },
                                    { win = "list", border = "none" },
                                },
                            },
                        },
                    },
                },
            })
            _G.bt = snacks.debug.backtrace
            _G.dd = snacks.debug.inspect
            vim.print = snacks.debug.inspect
        end,
    },
}
