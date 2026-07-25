return {
    {
        "dlyongemallo/diffview-plus.nvim",
        event = "VeryLazy",
        keys = {
            { "<localleader>dv", "<cmd>DiffviewOpen<CR>", desc = "Diff View: Open" },
            { "<localleader>dh", "<cmd>DiffviewFileHistory<CR>", desc = "Diff View: File History" },
        },
        config = function()
            require("diffview").setup({
                enhanced_diff_hl = true,
                diffopt = {
                    linematch = 60,
                    algorithm = "histogram",
                },
                file_panel = {
                    show_branch_name = true,
                },
                file_history_panel = {
                    subject_highlight = "merge_aware",
                },
                view = {
                    default = {
                        winbar_info = true,
                    },
                    merge_tool = {
                        layout = "diff4_mixed",
                        disable_diagnostics = true,
                        winbar_info = true,
                    },
                    cycle_layouts = {
                        merge_tool = { "diff4_mixed", "diff3_mixed", "diff3_horizontal", "diff1_plain" },
                    },
                },
                hooks = {
                    diff_buf_win_enter = function(_, winid, ctx)
                        vim.schedule(function()
                            -- only touch the 2-way diff layouts
                            if ctx.layout_name == "diff2_horizontal" or ctx.layout_name == "diff2_vertical" then
                                if ctx.symbol == "a" then -- old / left
                                    -- vim.opt_local.winhl = table.concat({
                                    --     "DiffText:DiffTextDelete",
                                    --     "DiffAdd:DiffDelete",
                                    --     "DiffChange:DiffDelete",
                                    -- })
                                    vim.wo[winid].winhl = table.concat({
                                        vim.wo[winid].winhl,
                                        "DiffText:DiffTextDelete",
                                        "DiffTextAdd:DiffTextDelete",
                                        "DiffAdd:DiffDelete",
                                        "DiffChange:DiffDelete",
                                    }, ",")
                                elseif ctx.symbol == "b" then -- new / right
                                    vim.wo[winid].winhl = table.concat({
                                        vim.wo[winid].winhl,
                                        "DiffText:DiffTextAdd",
                                        "DiffChange:DiffAdd",
                                    }, ",")
                                end
                            end
                        end)
                    end,
                },
            })
        end,
    },
}
