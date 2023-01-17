local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
    pickers = {
        find_files = {
            find_command = {
                "fd",
            },
            hidden = true,
        },
    },
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--hidden",
            "--smart-case",
        },
        history = {
            path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
            limit = 1000,
        },
        mappings = {
            i = {
                ["<C-d>"] = actions.cycle_history_next,
                ["<C-s>"] = actions.cycle_history_prev,
            },
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "flex",
        layout_config = {
            vertical = {
                prompt_position = "top",
                width = 0.90,
                height = 0.98,
                preview_height = 0.65,
            },
            horizontal = {
                prompt_position = "top",
                width = 0.90,
                height = 0.98,
                preview_width = 0.70,
            },
            flex = {
                flip_cloumns = 120,
            },
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { " ", "", "", "", "", "", "", "" },
        results_title = false,
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" },
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    },
    extensions = {
        media_files = {
            filetypes = { "png", "webp", "jpg", "jpeg" },
            find_cmd = "rg",
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
        },
        undo = {
            side_by_side = true,
            use_delta = true,
            mappings = {
                i = {
                    ["<C-cr>"] = require("telescope-undo.actions").yank_additions,
                    ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                    ["<cr>"] = require("telescope-undo.actions").restore,
                },
            },
            layout_strategy = "vertical",
            layout_config = {
                preview_height = 0.8,
            },
        },
    },
})

telescope.load_extension("media_files")
telescope.load_extension("find_directories")
telescope.load_extension("file_browser")
telescope.load_extension("notify")
telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("smart_history")
telescope.load_extension("undo")

vim.api.nvim_create_user_command("Search", function()
    -- Thank you u/SPEKTRUMdagreat :)
    local search = vim.fn.input("Search: ")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    ---@diagnostic disable-next-line: redefined-local
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- our picker function: colors
    local searcher = function(opts)
        opts = opts or {}
        pickers
            .new(opts, {
                prompt_title = "OmniSearch",
                finder = finders.new_table({
                    results = {
                        { "Stack Overflow", ("www.stackoverflow.com/search\\?q\\=" .. search:gsub(" ", "+")) },
                        { "Google Search", ("www.google.com/search\\?q\\=" .. search:gsub(" ", "+")) },
                        { "Youtube", ("https://www.youtube.com/results\\?search_query\\=" .. search:gsub(" ", "+")) },
                        { "Wikipedia", ("https://en.wikipedia.org/w/index.php\\?search\\=" .. search:gsub(" ", "+")) },
                        { "Github", ("https://github.com/search\\?q\\=" .. search:gsub(" ", "+")) },
                    },
                    entry_maker = function(entry)
                        return { value = entry, display = entry[1], ordinal = entry[1] }
                    end,
                }),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        vim.cmd(("silent execute '!firefox-developer-edition %s &'"):format(selection["value"][2]))
                    end)
                    return true
                end,
            })
            :find()
    end
    searcher(require("telescope.themes").get_dropdown({}))
end, { nargs = 0 })
