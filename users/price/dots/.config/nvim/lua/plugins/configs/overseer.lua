return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerRun",
            "OverseerShell",
            "OverseerTaskAction",
        },
        keys = {
            { "<leader>r", desc = "Overseer" },
            { "<leader>rs", "<cmd>OverseerRun<CR>", desc = "Overseer: Run" },
            { "<leader>rr", "<cmd>OverseerToggle<CR>", desc = "Overseer: Toggle" },
        },
        config = function()
            local overseer = require("overseer")
            overseer.setup({
                actions = {
                    ["Send SIGINT"] = {
                        desc = "Ctrl-C",
                        condition = function(task)
                            return task:is_running() and task.strategy and task.strategy.job_id
                        end,
                        run = function(task)
                            local pid = vim.fn.jobpid(task.strategy.job_id)
                            vim.uv.kill(pid, vim.uv.constants.SIGINT)
                        end,
                    },
                },
            })
            local tempname_caches = {}

            --- Get a temp file bound to the bufnr
            local function tempname()
                local bufnr = vim.api.nvim_get_current_buf()
                if not tempname_caches[bufnr] then
                    tempname_caches[bufnr] = vim.fn.tempname()
                end
                return tempname_caches[bufnr]
            end
            overseer.register_template({
                name = "Watch Typst",
                desc = "Run `typst watch` and view the PDF",
                builder = function(_)
                    return {
                        cmd = {
                            "typst",
                            "watch",
                            "--open=xdg-open",
                            vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
                            tempname() .. ".pdf",
                        },
                    }
                end,
                condition = {
                    filetype = "typst",
                },
            })
            overseer.register_template({
                name = "Run Live Server (CWD)",
                desc = "Run `live-server` for the CWD",
                builder = function(_)
                    return {
                        cmd = {
                            "live-server",
                            "-H",
                            "localhost",
                            "-o",
                            "--index",
                        },
                    }
                end,
            })
            overseer.register_template({
                name = "Run Live Server (Buf)",
                desc = "Run `live-server` for the directory of the current buffer",
                builder = function(_)
                    local bufpath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
                    local dir = vim.fs.dirname(bufpath)
                    return {
                        cmd = {
                            "live-server",
                            "-H",
                            "localhost",
                            "-o",
                            "--index",
                            dir,
                        },
                    }
                end,
            })
            overseer.register_template({
                name = "Watch D2",
                desc = "Run `d2 --watch`",
                builder = function(_)
                    return {
                        cmd = {
                            "d2",
                            "--watch",
                            vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
                        },
                    }
                end,
                condition = {
                    filetype = "d2",
                },
            })
        end,
    },
}
