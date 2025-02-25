return {
    {
        "nvim-orgmode/orgmode",
        event = "VeryLazy",
        cmd = { "Org" },
        ft = { "org" },
        keys = {
            { "<leader>o", desc = "> Org" },
        },
        config = function()
            local org = require("orgmode")

            ---@generic T
            ---@param tasks T[]
            ---@return T[]
            local function dedup_notif_tasks(tasks)
                local unique_tasks = {}
                for _, task in ipairs(tasks) do
                    local task_unique = true
                    ---@type OrgRange
                    local task_range = task.range
                    for _, ret_task in ipairs(unique_tasks) do
                        ---@type OrgRange
                        local ret_task_range = ret_task.range
                        if
                            task_range.start_line == ret_task_range.start_line
                            and task_range.end_line == ret_task_range.end_line
                        then
                            task_unique = false
                            break
                        end
                    end
                    if task_unique then
                        table.insert(unique_tasks, task)
                    end
                end
                return unique_tasks
            end

            ---@class meta.OrgNotification
            ---@field msg string
            ---@field task any
            ---@field header string

            ---@return meta.OrgNotification[]
            local function build_task_notifications(tasks)
                ---@type meta.OrgNotification[]
                local notifications = {}
                for _, task in ipairs(dedup_notif_tasks(tasks)) do
                    local new_task = {}
                    local title = {
                        string.rep("*", task.level),
                        task.todo,
                    }
                    if task.priority ~= "" then
                        table.insert(title, ("[#%s]"):format(task.priority))
                    end
                    table.insert(title, task.title)
                    table.insert(new_task, table.concat(title, " "))
                    table.insert(new_task, string.format("%s: <%s>", task.type, task.time:to_string()))

                    local built_msg = table.concat(new_task, "\n")
                    table.insert(notifications, {
                        msg = built_msg,
                        task = task,
                        header = string.format("%s (%s)", task.category, task.humanized_duration),
                    })
                end
                return notifications
            end

            local hour = 60
            local reminder_times = { 24 * hour, 12 * hour, 8 * hour, 4 * hour, 2 * hour, hour, 30, 10, 0 }

            org.setup({
                mappings = {
                    agenda = {
                        org_agenda_filter = "F",
                    },
                },
                org_agenda_files = {
                    "~/Git/College/*",
                    "~/Git/College/*/*",
                    "~/Git/College/*/*/*",
                    "~/Git/Projects/Blog/*",
                    "~/Git/Projects/Blog/docs/**/*",
                    "~/Notes/**/*",
                    "~/.config/home-manager/*",
                    "~/.config/home-manager/docs/**/*",
                    vim.fn.stdpath("config") .. "/**/*",
                },
                notifications = {
                    enabled = true,
                    cron_enabled = true,
                    repeater_reminder_time = reminder_times,
                    deadline_warning_reminder_time = reminder_times,
                    reminder_time = reminder_times,
                    notifier = function(tasks)
                        local notifications = build_task_notifications(tasks)
                        local msgs = {}
                        if #notifications > 0 then
                            for _, notif in ipairs(notifications) do
                                table.insert(msgs, ("# %s\n%s"):format(notif.header, notif.msg))
                            end
                            vim.notify(table.concat(msgs, "\n\n"), vim.log.levels.INFO, {
                                timeout = 0,
                                title = "Orgmode Reminder",
                                ft = "org",
                                icon = "",
                                hl = {
                                    title = "@markup.heading.3",
                                    border = "@markup.heading.5",
                                },
                            })
                        end
                    end,
                    cron_notifier = function(tasks)
                        for _, notif in ipairs(build_task_notifications(tasks)) do
                            local msg = {
                                "========= Sending Task =========",
                                "> " .. table.concat(vim.split(notif.msg, "\n"), "\n> "),
                                "================================",
                            }
                            print(table.concat(msg, "\n"))
                            vim.system({
                                "notify-send",
                                ("--icon=%s/assets/nvim-orgmode-small.png"):format(
                                    require("lazy.core.config").options.root .. "/orgmode/"
                                ),
                                "--app-name=orgmode",
                                "--expire-time=0",
                                notif.header,
                                notif.msg,
                            })
                        end
                    end,
                },
                org_id_link_to_org_use_id = true,
                org_default_notes_file = "~/Notes/notes.org",
                org_highlight_latex_and_related = "entities",
                calendar_week_start_day = 0,
                org_log_into_drawer = "LOGBOOK",
                org_tags_column = 0,
                org_deadline_warning_days = 0,
                org_agenda_start_on_weekday = false,
                org_agenda_span = "month",
                org_startup_folded = "inherit",
                win_border = "none",
                org_hide_emphasis_markers = true,
                org_startup_indented = false,
                org_adapt_indentation = false,
                org_todo_keywords = { "TODO(t)", "WAIT(w)", "|", "DONE(d)", "CANCELLED(c)" },
                org_todo_keyword_faces = {
                    CANCELLED = ":weight bold",
                    WAIT = ":weight bold",
                },
                win_split_mode = "auto",
                org_capture_templates = {
                    t = {
                        description = "Todo",
                        template = "* TODO %?\nSCHEDULED: %T",
                        target = "~/Notes/todo.org",
                    },
                    n = {
                        description = "Note",
                        template = "* %?",
                    },
                    j = {
                        description = "Journal",
                        template = "* %?",
                        target = "~/Notes/journal.org",
                        datetree = true,
                    },
                    s = {
                        description = "Snippet",
                        template = "* %?",
                        target = "~/Notes/snippets.org",
                        datetree = false,
                    },
                },
            })

            vim.api.nvim_set_hl(0, "org_code_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_verbatim_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_italic_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_bold_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_underline_delimiter", { link = "@punctuation.delimiter" })
            vim.api.nvim_set_hl(0, "org_strikethrough_delimiter", { link = "@punctuation.delimiter" })
        end,
    },
    {
        "nvim-orgmode/telescope-orgmode.nvim",
        dependencies = {
            "nvim-orgmode/orgmode",
            "nvim-telescope/telescope.nvim",
        },
        cmd = {
            "Telescope orgmode search_headings",
            "Telescope orgmode refile_heading",
        },
        keys = {
            { "<leader>os", desc = "> Orgmode Telescope" },
            {
                "<leader>oss",
                ":Telescope orgmode search_headings<CR>",
                desc = "Telescope: Orgmode Search Headings",
                silent = true,
            },
            {
                "<leader>osr",
                ":Telescope orgmode refile_heading<CR>",
                desc = "Telescope: Orgmode Refile Heading",
                silent = true,
            },
            {
                "<leader>osi",
                ":Telescope orgmode insert_link<CR>",
                desc = "Telescope: Orgmode Insert Link",
                silent = true,
            },
        },
        config = function()
            require("telescope").load_extension("orgmode")
        end,
    },
}
