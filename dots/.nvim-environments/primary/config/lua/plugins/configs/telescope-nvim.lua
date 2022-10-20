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
    },
})

telescope.load_extension("media_files")
telescope.load_extension("find_directories")
telescope.load_extension("file_browser")
telescope.load_extension("notify")
telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("smart_history")
