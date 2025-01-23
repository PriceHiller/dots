return {
    {
        "nvim-orgmode/orgmode",
        event = "VeryLazy",
        ft = { "org" },
        keys = {
            { "<leader>o", desc = "> Org" },
        },
        config = function()
            local org = require("orgmode")
            local agenda_globs = {
                "~/Git/College/*",
                "~/Git/College/*/*",
                "~/Git/College/*/*/*",
                "~/Git/Projects/Blog/*",
                "~/Git/Projects/Blog/docs/**/*",
                "~/Notes/**/*",
                "~/.config/home-manager/*",
                "~/.config/home-manager/docs/**/*",
                vim.fn.stdpath("config") .. "/**/*",
            }
            org.setup({
                mappings = {
                    agenda = {
                        org_agenda_filter = "F",
                    },
                },
                org_agenda_files = agenda_globs,
                notifications = {
                    enabled = true,
                    cron_enabled = true,
                    repeater_reminder_time = { 2880, 1440, 720, 360, 180, 60, 30, 15, 10, 5, 0 },
                    deadline_warning_reminder_time = { 2880, 1440, 720, 360, 180, 60, 30, 15, 10, 5, 0 },
                    reminder_time = { 2880, 1440, 720, 360, 180, 60, 30, 15, 10, 5, 0 },
                    notifier = function(tasks)
                        local msg = {}
                        for _, task in ipairs(tasks) do
                            local new_task = {}
                            table.insert(new_task, string.format("# %s (%s)", task.category, task.humanized_duration))
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

                            table.insert(msg, table.concat(new_task, "\n"))
                        end
                        if #msg > 1 then
                            vim.notify(table.concat(msg, "\n\n"), vim.log.levels.INFO, {
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
                emacs_config = {
                    config_path = (function()
                        local xdg_emacs_init_path = "/emacs/init.el"

                        -- Use XDG_CONFIG_HOME by default
                        if vim.env.XDG_CONFIG_HOME then
                            return vim.env.XDG_CONFIG_HOME .. xdg_emacs_init_path
                        end

                        -- Fallback to searching for the emacs config relative to the Neovim config
                        local nvim_cfg_dir = vim.fn.stdpath("config")
                        ---@diagnostic disable-next-line: param-type-mismatch
                        local cfg_dir = vim.fn.fnamemodify(nvim_cfg_dir, ":h")
                        if vim.uv.fs_stat(cfg_dir .. xdg_emacs_init_path) then
                            return cfg_dir .. xdg_emacs_init_path
                        end

                        -- Failing that, fallback to pulling on `$HOME/.emacs/init.el`
                        local home_emacs_init = vim.env.HOME .. ".emacs/init.el"
                        assert(vim.uv.fs_stat(home_emacs_init), "Failed to locate a valid emacs configuration!")
                        return home_emacs_init
                    end)(),
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
