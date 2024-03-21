return {
    {
        "luukvbaal/statuscol.nvim",
        opts = function()
            local builtin = require("statuscol.builtin")
            local last_sign_def_len = 0

            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                desc = "Ensure Neogit Status doesn't fuck the gutter up -- 🤮",
                pattern = "*Neogit*",
                callback = function()
                    local win = vim.api.nvim_get_current_win()
                    local set_opts = function()
                        vim.wo[win].statuscolumn = [[%!v:lua.StatusCol()]]
                        vim.wo[win].foldcolumn = "1"
                    end
                    set_opts()
                    vim.defer_fn(set_opts, 10)
                    vim.defer_fn(set_opts, 20)
                    vim.defer_fn(set_opts, 30)
                    vim.defer_fn(set_opts, 50)
                    vim.defer_fn(set_opts, 100)
                end,
            })

            return {
                setopt = true,
                relculright = false,
                segments = {
                    { text = { "%s" }, click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
                },
            }
        end,
    },
}
