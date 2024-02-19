return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = {
            "Telescope",
        },
        keys = {
            {
                "<leader>lq",
                ":Telescope diagnostics bufnr=0<CR>",
                desc = "LSP: Telescope Diagnostics",
            },
            { "<leader>t", desc = "> Telescope" },
            { "<leader>tg", desc = "> Telescope: Git" },
            { "<leader>tw", ":Telescope live_grep<CR>", desc = "Telescope: Grep for Word" },
            { "<leader>tgs", ":Telescope git_status<CR>", desc = "Telescope: Git Status" },
            { "<leader>tgc", ":Telescope git_commits<CR>", desc = "Telescope: Git Commits" },
            { "<leader>tgb", ":Telescope git_branches<CR>", desc = "Telescope: Git Branches" },
            { "<leader>tf", ":Telescope find_files<CR>", desc = "Telescope: Find Files" },
            { "<leader>td", ":Telescope find_directories<CR>", desc = "Telescope: Find Directories" },
            { "<leader>tb", ":Telescope buffers<CR>", desc = "Telescope: Buffers" },
            { "<leader>th", ":Telescope help_tags<CR>", desc = "Telescope: Help Tags" },
            { "<leader>to", ":Telescope oldfiles<CR>", desc = "Telescope: Recent Files" },
            { "<leader>tn", ":Telescope neoclip default<CR>", desc = "Telescope: Neoclip Buffer" },
            { "<leader>tr", ":Telescope resume<CR>", desc = "Telescope: Resume" },
            { "<leader>tR", ":Telescope registers<CR>", desc = "Telescope: Registers" },
            { "<leader>ts", ":Telescope spell_suggest<CR>", desc = "Telescope: Spell Suggest" },
            { "<leader>tl", ":Telescope resume<CR>", desc = "Telescope: Previous State" },
            { "<leader>tT", ":TodoTelescope<CR>", desc = "Telescope: Todo Items" },
            { "<leader>tk", ":Telescope keymaps<CR>", desc = "Telescope: Keymaps" },
            { "<leader>tc", ":Telescope commands<CR>", desc = "Telescope: Commands" },
            { "<leader>tu", ":Telescope undo<CR>", desc = "Telescope: Undo History" },
            { "<leader>tm", ":Telescope man_pages<CR>", desc = "Telescope: Man Pages" },
            { "<leader>tq", ":Telescope quickfixhistry", desc = "LSP: Telescope Quickfix History" },
            { "<leader>nv", ":Telescope notify<CR>", desc = "Notifications: Search" },
            { "<leader>tt", ":Telescope<CR>", desc = "Telescope: Open Telescope" },
        },
        dependencies = {
            "artart222/telescope_find_directories",
            "nvim-telescope/telescope-ui-select.nvim",
            {
                "nvim-telescope/telescope-frecency.nvim",
                cmd = {
                    "FrecencyMigrateDB",
                    "FrecencyValidate",
                    "FrecencyDelete",
                },
            },
            "debugloop/telescope-undo.nvim",
            "rcarriga/nvim-notify",
            { "nvim-telescope/telescope-smart-history.nvim", dependencies = "tami5/sqlite.lua" },
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
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                        "--glob=!.git/*"
                    },
                    history = {
                        path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
                        limit = 1000,
                    },
                    mappings = {
                        i = {
                            ["<C-d>"] = actions.cycle_history_next,
                            ["<C-s>"] = actions.cycle_history_prev,
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
                    frecency = {
                        db_safe_mode = false,
                        auto_validate = false,
                    },
                },
            })

            telescope.load_extension("find_directories")
            telescope.load_extension("notify")
            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")
            telescope.load_extension("smart_history")
            telescope.load_extension("undo")
            telescope.load_extension("frecency")
        end,
    },
}
