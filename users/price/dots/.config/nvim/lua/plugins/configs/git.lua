return {
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
        "lewis6991/gitsigns.nvim",
        lazy = false,
        keys = {
            { "]g", "<cmd>Gitsigns next_hunk<CR><CR>", desc = "Gitsigns: Next Hunk" },
            { "[g", "<cmd>Gitsigns prev_hunk<CR><CR>", desc = "Gitsigns: Prev Hunk" },
        },
        config = function()
            require("gitsigns").setup({
                current_line_blame = true,
                current_line_blame_opts = {
                    delay = 0,
                },
            })
        end,
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

            local gitea_router = function(type)
                return function(lk)
                    local builder = "https://"
                        .. lk.host
                        .. "/"
                        .. lk.org
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
                        builder = builder .. "-L" .. lk.lend
                    end
                    return builder
                end
            end
            return {
                router = {
                    browse = {
                        ["^git%.price%-hiller%.com"] = gitea_router("src"),
                        ["^git%.price%hiller%.com"] = gitea_router("src"),
                    },
                    blame = {
                        ["^git%.price%-hiller%.com"] = gitea_router("blame/commit"),
                        ["^git%.price%hiller%.com"] = gitea_router("blame/commit"),
                    },
                },
            }
        end,
    },
}
