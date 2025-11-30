local initial_nvim_listen_addr = vim.env.NVIM_LISTEN_ADDRESS

return {
    {
        "subnut/nvim-ghost.nvim",
        dependencies = {
            "willothy/flatten.nvim",
        },
        init = function()
            vim.g.nvim_ghost_autostart = 0
        end,
        config = function()
            local augroup = vim.api.nvim_create_augroup("nvim_ghost_user_autocommands", { clear = false })
            ---@param opts vim.api.keyset.create_autocmd
            local mk_ghost_autocmd = function(opts)
                opts.group = augroup
                vim.api.nvim_create_autocmd("User", opts)
            end
            mk_ghost_autocmd({
                pattern = "kagi.com",
                callback = function(args)
                    vim.bo[args.buf].filetype = "markdown"
                end,
            })
            -- HACK: Reset the nvim listen address so we don't run into issues
            -- where other programs/plugins will reuse an existing socket
            vim.env.NVIM_LISTEN_ADDRESS = initial_nvim_listen_addr
            vim.cmd("silent! GhostTextStart")
        end,
    },
}
