return {
    {
        "nvim-telescope/telescope.nvim",
        event = "DirChanged",
        cmd = {
            "Telescope",
            "FrecencyMigrateDB",
            "FrecencyValidate",
            "FrecencyDelete",
        },
        dependencies = {
            "nvim-telescope/telescope-z.nvim",
            {
                "nvim-telescope/telescope-frecency.nvim",
            },
            "debugloop/telescope-undo.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                pickers = {
                    find_files = {
                        find_command = {
                            "fd",
                            "--hidden",
                            "--type",
                            "f",
                            "--strip-cwd-prefix",
                            "--exclude",
                            ".git/",
                        },
                    },
                },
                defaults = {
                    ---@diagnostic disable-next-line: undefined-field
                    winblend = vim.opt.winblend:get(),
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                        "--glob=!.git/*",
                    },
                    history = {
                        path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
                        limit = 1000,
                    },
                    mappings = {
                        i = {
                            ["<Tab>"] = actions.toggle_selection,
                            ["<C-j>"] = actions.preview_scrolling_down,
                            ["<C-k>"] = actions.preview_scrolling_up,
                            ["<A-s>"] = actions.preview_scrolling_up,
                            ["<A-a>"] = actions.preview_scrolling_down,
                            ["<C-h>"] = actions.preview_scrolling_left,
                            ["<C-l>"] = actions.preview_scrolling_right,
                            ["<C-d>"] = actions.cycle_history_next,
                            ["<A-x>"] = actions.delete_buffer,
                            ["<C-s>"] = actions.cycle_history_prev,
                            ["<C-q>"] = actions.smart_send_to_qflist,
                        },
                        n = {
                            ["<C-q>"] = actions.smart_send_to_qflist,
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
                    frecency = {
                        show_scores = true,
                        auto_validate = true,
                        db_safe_mode = false,
                    },
                },
            })

            telescope.load_extension("fzf")
            telescope.load_extension("undo")
            telescope.load_extension("frecency")
            telescope.load_extension("z")
        end,
    },
}
