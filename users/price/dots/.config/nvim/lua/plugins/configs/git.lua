return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 0,
            },
        },
    },
    {
        "sindrets/diffview.nvim",
        keys = {
            { "<localleader>d", desc = "> Diff View" },
            { "<localleader>dd", "<cmd>DiffviewOpen<CR>", desc = "Diff View: Open" },
            { "<localleader>dh", "<cmd>DiffviewFileHistory<CR>", desc = "Diff View: File History" },
        },
        cmd = {
            "DiffviewToggleFiles",
            "DiffviewFileHistory",
            "DiffviewFocusFiles",
            "DiffviewRefresh",
            "DiffviewClose",
            "DiffviewOpen",
            "DiffviewLog",
        },
        opts = {
            enhanced_diff_hl = true,
        },
    },
    {
        "neogitorg/neogit",
        cmd = { "Neogit" },
        keys = {
            { "<leader>g", desc = "> Git" },
            { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit: Open" },
        },
        opts = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*Neogit*",
                callback = function()
                    vim.opt_local.list = false
                    vim.opt_local.foldmethod = "manual"
                end,
            })

            ---@type NeogitConfig
            return {
                disable_insert_on_commit = "auto",
                disable_commit_confirmation = true,
                disable_builtin_notifications = true,
                auto_refresh = true,
                auto_show_console = false,
                disable_signs = true,
                preview_buffer = {
                    kind = "split",
                },
                filewatcher = {
                    enabled = true,
                    interval = 1000,
                },
                graph_style = "unicode",
                integrations = {
                    diffview = true,
                    telescope = true,
                },
                mappings = {
                    popup = {
                        ["l"] = false,
                        ["L"] = "LogPopup",
                    },
                },
            }
        end,
        dependencies = {
            "sindrets/diffview.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "]g", "<cmd>Gitsigns next_hunk<CR><CR>", desc = "Gitsigns: Next Hunk" },
            { "[g", "<cmd>Gitsigns prev_hunk<CR><CR>", desc = "Gitsigns: Prev Hunk" },
            { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Gitsigns: Stage Hunk" },
            { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Gitsigns: Reset Hunk" },
            { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "Gitsigns: Unstage Hunk" },
        },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 0,
            },
        },
    },
    {
        "linrongbin16/gitlinker.nvim",
        cmd = {
            "GitLink",
        },
        opts = function()
            --- @param s string
            --- @param t string
            local function string_endswith(s, t)
                return string.len(s) >= string.len(t) and string.sub(s, #s - #t + 1) == t
            end

            --- @param lk gitlinker.Linker
            local gitlab_orion_router = function(type)
                return function(lk)
                    local builder = "https://"
                        .. lk.host
                        .. "/"
                        .. (string_endswith(lk.repo, ".git") and lk.repo:sub(1, #lk.repo - 4) or lk.repo)
                        .. "/"
                        .. type
                        .. "/"
                        .. lk.rev
                        .. "/"
                        .. lk.file
                        .. "#L"
                        .. lk.lstart

                    if lk.lend > lk.lstart then
                        builder = builder .. "-" .. lk.lend
                    end
                    return builder
                end
            end
            return {
                router = {
                    browse = {
                        ["^gitlab%.orion%-technologies%.io"] = gitlab_orion_router("blob"),
                    },
                    blame = {
                        ["^gitlab%.orion%-technologies%.io"] = gitlab_orion_router("blame"),
                    },
                },
            }
        end,
    },
}
