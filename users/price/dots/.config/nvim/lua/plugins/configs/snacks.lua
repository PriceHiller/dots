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
    end, { silent = true, buffer = bufnr, noremap = true, desc = "Quick Close Buffer" })
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
                function()
                    require("snacks").bufdelete.delete()
                end,
                desc = "Close Buffer",
                mode = { "", "!", "v", "t" },
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
                    require("snacks").picker.notifications()
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
                "<leader>fd",
                function()
                    require("snacks").picker({
                        finder = "proc",
                        title = "Directories",
                        cmd = "fd",
                        args = { "--type", "directory", "--hidden", "--exclude", ".git" },
                        transform = function(item)
                            item.file = item.text
                            item.dir = true
                        end,
                    })
                end,
                desc = "Pick: Directories",
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
                "<leader>fR",
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
            {
                "<leader>fs",
                function()
                    require("snacks").picker.spelling()
                end,
                desc = "Pick: Spelling",
            },
            {
                "<leader>ft",
                function()
                    ---@diagnostic disable-next-line: undefined-field
                    require("snacks").picker.todo_comments()
                end,
                desc = "Pick: Todo Comments",
            },
            {
                "<leader>fj",
                function()
                    require("snacks").picker.diagnostics()
                end,
                desc = "Pick: Diagnostics",
            },
            {
                "<leader>fk",
                function()
                    require("snacks").picker.diagnostics_buffer()
                end,
                desc = "Pick: Diagnostics Buffer",
            },
            {
                "<leader>fp",
                function()
                    require("snacks").picker.search_history()
                end,
                desc = "Pick: Previous Search History",
            },
            {
                "<leader>f?",
                function()
                    require("snacks").picker.help()
                end,
                desc = "Pick: :help",
            },
            {
                "<leader>gll",
                desc = "> Git Log",
            },
            {
                "<leader>gll",
                function()
                    require("snacks").picker.git_log()
                end,
                desc = "Pick: Git Log",
            },
            {
                "<leader>glf",
                function()
                    require("snacks").picker.git_log_file()
                end,
                desc = "Pick: Git Log File",
            },
            {
                "<leader>glL",
                function()
                    require("snacks").picker.git_log_line()
                end,
                desc = "Pick: Git Log Line",
            },
            {
                "<leader>gf",
                function()
                    require("snacks").picker.git_files()
                end,
                desc = "Pick: Git Files",
            },
            {
                "<leader>gw",
                function()
                    require("snacks").picker.git_grep()
                end,
                desc = "Pick: Git Grep",
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
                picker = {
                    matcher = {
                        cwd_bonus = true,
                        frecency = true,
                        history_bonus = true,
                    },
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
                        set_picker_cwd = function(picker, item)
                            if item then
                                picker:set_cwd(snacks.picker.util.dir(item))
                                picker:find({ refresh = true })
                            end
                        end,
                    },
                    win = {
                        input = {
                            keys = {
                                ["<C-l>"] = { "loclist", mode = { "i", "n" } },
                                ["<C-S-d>"] = { "set_picker_cwd", mode = { "n", "i" } },
                                ["<C-S-x>"] = { "cd", mode = { "n", "i" } },
                                ["<C-S-k>"] = { "history_forward", mode = { "i", "n" } },
                                ["<C-S-j>"] = { "history_back", mode = { "i", "n" } },
                            },
                        },
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
                    previewers = {
                        file = {
                            max_size = 100 * 2 ^ 20, -- 100MB
                        },
                    },
                    sources = {
                        notifications = {
                            formatters = {
                                severity = { level = false },
                            },
                            confirm = { "copy", "close" },
                        },
                        undo = {
                            win = {
                                input = {
                                    keys = {
                                        ["<C-S-a>"] = { "yank_add", mode = { "n", "i" } },
                                        ["<C-S-d>"] = { "yank_del", mode = { "n", "i" } },
                                    },
                                },
                            },
                        },
                        files = {
                            hidden = true,
                            ignored = false,
                            follow = true,
                        },
                        recent = {
                            ---@type snacks.picker.Filter
                            filter = {
                                filter = function(item)
                                    -- Ensure we only get back exactly what's in oldfiles
                                    return vim.list_contains(vim.v.oldfiles, item.file)
                                end,
                            },
                        },
                        grep = {
                            hidden = true,
                            ignored = false,
                            follow = true,
                        },
                        buffers = {
                            matcher = {
                                sort_empty = true,
                                on_match = function(_, item)
                                    ---@type string?
                                    local flags = item.flags
                                    if not flags then
                                        return
                                    end

                                    if flags:find("#") then
                                        item.score = 20000
                                    end

                                    if flags:find("%%") then
                                        item.score = 0
                                    end
                                end,
                            },
                            win = {
                                input = {
                                    keys = {
                                        ["<A-x>"] = { "bufdelete", mode = { "n", "i" } },
                                    },
                                },
                            },
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

            if snacks.config.notifier.enabled then
                vim.print = snacks.debug.inspect
            end
            _G.bt = snacks.debug.backtrace
            _G.dd = snacks.debug.inspect
        end,
    },
}
