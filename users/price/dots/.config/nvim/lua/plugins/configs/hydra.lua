return {
    {
        -- "nvimtools/hydra.nvim",
        -- TODO: Point this back to `nvimtools` once they decide to update to support nightly
        "Cathyprime/hydra.nvim",
        dependencies = {
            "lewis6991/gitsigns.nvim",
            "jbyuki/venn.nvim",
            "folke/which-key.nvim",
        },
        keys = {
            { "<leader>h", desc = "> Hydra" },
            { "<C-w>>" },
            { "<C-w><" },
            { "<C-w>+" },
            { "<C-w>-" },
            { "zl" },
            { "zL" },
            { "zh" },
            { "zH" },
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local hydra = require("hydra")

            -- Side Scroll
            hydra({
                name = "Side scroll",
                mode = "n",
                body = "z",
                config = {
                    hint = {
                        type = "window",
                    },
                },
                heads = {
                    { "h", "5zh" },
                    { "l", "5zl", { desc = "←/→" } },
                    { "H", "zH" },
                    { "L", "zL", { desc = "half screen ←/→" } },
                },
            })

            -- Git Integration
            local gitsigns = require("gitsigns")

            local hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo stage hunk   _p_: preview hunk   _B_: blame show full
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _<Enter>_: Neogit              _q_: exit
]]

            hydra({
                name = "Git",
                hint = hint,
                config = {
                    color = "pink",
                    invoke_on_body = true,
                    hint = {
                        position = "bottom-right",
                    },
                    on_enter = function()
                        vim.bo.modifiable = false
                        gitsigns.toggle_signs(true)
                        gitsigns.toggle_linehl(true)
                    end,
                    on_exit = function()
                        gitsigns.toggle_signs(false)
                        gitsigns.toggle_linehl(false)
                        gitsigns.toggle_deleted(false)
                    end,
                },
                mode = { "n", "x" },
                body = "<leader>hg",
                heads = {
                    {
                        "J",
                        function()
                            if vim.wo.diff then
                                return "]c"
                            end
                            vim.schedule(function()
                                gitsigns.next_hunk()
                            end)
                            return "<Ignore>"
                        end,
                        { expr = true },
                    },
                    {
                        "K",
                        function()
                            if vim.wo.diff then
                                return "[c"
                            end
                            vim.schedule(function()
                                gitsigns.prev_hunk()
                            end)
                            return "<Ignore>"
                        end,
                        { expr = true },
                    },
                    { "s", ":Gitsigns stage_hunk<CR>", { silent = true } },
                    { "u", gitsigns.undo_stage_hunk },
                    { "S", gitsigns.stage_buffer },
                    { "p", gitsigns.preview_hunk },
                    { "d", gitsigns.toggle_deleted, { nowait = true } },
                    { "b", gitsigns.blame_line },
                    {
                        "B",
                        function()
                            gitsigns.blame_line({ full = true })
                        end,
                    },
                    { "/", gitsigns.show, { exit = true } }, -- show the base of the file
                    { "<Enter>", "<cmd>Neogit<CR>", { exit = true } },
                    { "q", nil, { exit = true, nowait = true } },
                },
            })

            -- Hydra to repeat expanding windows
            hydra({
                name = "Window Sizing",
                mode = "n",
                body = "<C-w>",
                config = {
                    hint = {
                        type = "window",
                    },
                },
                heads = {
                    { "<", "2<C-w><" },
                    { ">", "2<C-w>>", { desc = "←/→" } },
                    { "+", "2<C-w>+" },
                    { "-", "2<C-w>-", { desc = "↑/↓" } },
                },
            })

            -- Hydra for DAP
            hydra({
                name = "Debug",
                mode = "n",
                body = "<leader>hd",
                hint = [[
^^Debug
^
_c_: Continue/Start       _r_: Run Last                 _e_: End/Stop
_b_: Toggle Breakpoint    _l_: Toggle Log Breakpoint    _B_: Toggle Conditional Breakpoint

^^                _s_: Toggle DAP UI               _R_: Run to cursor

^^                _<F5>_: Step Over                _<F6>_: Step Into
^^                _<F7>_: Step Out                 _<F8>_: Step Back
                ]],
                heads = {
                    { "c", ":DapContinue<CR>" },
                    { "r", require("dap").run_last },
                    { "e", ":DapTerminate<CR>" },
                    { "b", ":DapToggleBreakpoint<CR>" },
                    {
                        "B",
                        function()
                            require("dap").set_breakpoint(vim.fn.input("Breakpoint Condition: "))
                        end,
                    },
                    {
                        "l",
                        function()
                            require("dap").set_breakpoint(vim.fn.input("Breakpoint Condition: "))
                        end,
                    },
                    { "s", require("dapui").toggle },
                    { "R", require("dap").run_to_cursor },
                    { "<F5>", ":DapStepOver<CR>" },
                    { "<F6>", ":DapStepInto<CR>" },
                    { "<F7>", ":DapStepOut<CR>" },
                    { "<F8>", require("dap").step_back },
                },
                config = {
                    color = "pink",
                    invoke_on_body = true,
                    hint = {},
                },
            })

            -- Hydra for diagrams

            hydra({
                name = "Draw Diagram",
                hint = [[
 Arrow^^^^^^   Select region with <C-v>
 ^ ^ _K_ ^ ^   _f_: surround it with box
 _H_ ^ ^ _L_
 ^ ^ _J_ ^ ^                      _<Esc>_
]],
                config = {
                    color = "pink",
                    invoke_on_body = true,
                    hint = {},
                    on_enter = function()
                        vim.o.virtualedit = "all"
                        vim.o.cursorline = true
                        vim.o.cursorcolumn = true
                    end,
                },
                mode = "n",
                body = "<leader>hD",
                heads = {
                    { "H", "<C-v>h:VBox<CR>" },
                    { "J", "<C-v>j:VBox<CR>" },
                    { "K", "<C-v>k:VBox<CR>" },
                    { "L", "<C-v>l:VBox<CR>" },
                    { "f", ":VBox<CR>", { mode = "v" } },
                    { "<Esc>", nil, { exit = true } },
                },
            })

            hydra({
                name = "Options",
                hint = [[
  ^ ^        Options
  ^
  _v_ %{ve} virtual edit
  _i_ %{list} invisible characters
  _s_ %{spell} spell
  _w_ %{wrap} wrap
  _c_ %{cul} cursor line
  _n_ %{nu} number
  _r_ %{rnu} relative number
  ^
       ^^^^                _<Esc>_
]],
                config = {
                    color = "amaranth",
                    invoke_on_body = true,
                    hint = {
                        position = "middle",
                    },
                },
                mode = { "n", "x" },
                body = "<leader>ho",
                heads = {
                    {
                        "n",
                        function()
                            if vim.o.number == true then
                                vim.o.number = false
                            else
                                vim.o.number = true
                            end
                        end,
                        { desc = "number" },
                    },
                    {
                        "r",
                        function()
                            if vim.o.relativenumber == true then
                                vim.o.relativenumber = false
                            else
                                vim.o.number = true
                                vim.o.relativenumber = true
                            end
                        end,
                        { desc = "relativenumber" },
                    },
                    {
                        "v",
                        function()
                            if vim.o.virtualedit == "all" then
                                vim.o.virtualedit = "block"
                            else
                                vim.o.virtualedit = "all"
                            end
                        end,
                        { desc = "virtualedit" },
                    },
                    {
                        "i",
                        function()
                            if vim.o.list == true then
                                vim.o.list = false
                            else
                                vim.o.list = true
                            end
                        end,
                        { desc = "show invisible" },
                    },
                    {
                        "s",
                        function()
                            if vim.o.spell == true then
                                vim.o.spell = false
                            else
                                vim.o.spell = true
                            end
                        end,
                        { desc = "spell" },
                    },
                    {
                        "w",
                        function()
                            if vim.o.wrap ~= true then
                                vim.o.wrap = true
                                -- Dealing with word wrap:
                                -- If cursor is inside very long line in the file than wraps
                                -- around several rows on the screen, then 'j' key moves you to
                                -- the next line in the file, but not to the next row on the
                                -- screen under your previous position as in other editors. These
                                -- bindings fixes this.
                                vim.keymap.set("n", "k", function()
                                    return vim.v.count > 0 and "k" or "gk"
                                end, { expr = true, desc = "k or gk" })
                                vim.keymap.set("n", "j", function()
                                    return vim.v.count > 0 and "j" or "gj"
                                end, { expr = true, desc = "j or gj" })
                            else
                                vim.o.wrap = false
                                vim.keymap.del("n", "k")
                                vim.keymap.del("n", "j")
                            end
                        end,
                        { desc = "wrap" },
                    },
                    {
                        "c",
                        function()
                            if vim.o.cursorline == true then
                                vim.o.cursorline = false
                            else
                                vim.o.cursorline = true
                            end
                        end,
                        { desc = "cursor line" },
                    },
                    { "<Esc>", nil, { exit = true } },
                },
            })
        end,
    },
}
