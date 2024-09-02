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
                org_todo_keywords = { "TODO(t)", "WAIT(n)", "|", "DONE(d)", "CANCELLED(c)" },
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
                        target = "~/Notes/journal.org",
                        datetree = true,
                    },
                    s = {
                        description = "Snippet",
                        template = "* %? :snippet:",
                        target = "~/Notes/snippets.org",
                        datetree = true,
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

            -- NOTE: Everything below is an attempt to get orgmode to sync between different Neovim
            -- instaces. Ideally Orgmode would write to a central state file using Mutexes, but it
            -- doesn't. Thus my shitty code below.
            local watched_dirs = {}

            local function watch_dir(dir)
                local fs_watch = vim.uv.new_fs_event()
                if not fs_watch then
                    error("Failed to create a fs watch for dir: " .. dir)
                end
                dir = vim.fn.fnamemodify(dir, ":p")
                if dir:sub(-1) == "/" then
                    dir = dir:sub(1, -2)
                end
                if vim.tbl_contains(watched_dirs, dir) then
                    return
                end
                table.insert(watched_dirs, dir)
                fs_watch:start(
                    dir,
                    {},
                    vim.schedule_wrap(function(_, fpath, _)
                        fpath = dir .. "/" .. fpath
                        if vim.fn.isdirectory(fpath) == 1 and not vim.tbl_contains(watched_dirs, fpath) then
                            watch_dir(fpath)
                            return
                        end

                        if vim.fn.fnamemodify(fpath, ":e") == "org" then
                            org.files:load(true)
                            org.clock:init()
                        end
                    end)
                )
            end

            vim.defer_fn(function()
                vim.wait(1000, function()
                    return org.initialized
                end)
                vim.iter(agenda_globs)
                    :map(function(glob)
                        glob = vim.fn.fnamemodify(glob, ":p")
                        local globs = vim.fn.glob(vim.fn.fnamemodify(glob, ":p"), false, true)
                        local base_glob_dir = glob:gsub("*/", ""):gsub("*", "")
                        table.insert(globs, base_glob_dir)
                        return globs
                    end)
                    :flatten()
                    :filter(function(f)
                        return vim.fn.isdirectory(f) == 1
                    end)
                    :map(watch_dir)
            end, 1000)
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
