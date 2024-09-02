return {
    {
        "jedrzejboczar/exrc.nvim",
        opts = {
            on_vim_enter = true,
            on_dir_changed = {
                enabled = true,
                use_ui_select = false,
            },
            trust_on_write = true,
            use_telescope = true,
            min_log_level = vim.log.levels.DEBUG,
            lsp = {
                auto_setup = false,
            },
            commands = {
                instant_edit_single = true,
            },
        },
    },
}
