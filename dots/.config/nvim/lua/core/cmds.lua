local M = {}
M.setup = function()
    vim.api.nvim_create_user_command("StripTrailSpace", "%s/\\s\\+$//e", {})
    vim.api.nvim_create_user_command("DiffSaved", function()
        -- Thanks to sindrets: https://github.com/sindrets/dotfiles/blob/1990282dba25aaf49897f0fc70ebb50f424fc9c4/.config/nvim/lua/user/lib.lua#L175
        -- Minor alterations by me
        local buf_ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
        local buf_name = vim.api.nvim_buf_get_name(0)
        vim.cmd("tab split | diffthis")
        vim.cmd("aboveleft vnew | r # | normal! 1Gdd")
        vim.cmd.diffthis()
        local opts = {
            buftype = "nowrite",
            bufhidden = "wipe",
            swapfile = false,
            readonly = true,
            winbar = vim.opt.winbar:get()
        }
        for option, value in pairs(opts) do
            vim.api.nvim_set_option_value(option, value, { scope = "local" })
        end
        if buf_name then
            pcall(vim.api.nvim_buf_set_name, 0, (vim.fn.fnamemodify(buf_name, ":t") or buf_name) .. " [OLD]")
        end
        if buf_ft then
            vim.opt_local.filetype = buf_ft
        end
        vim.cmd.wincmd("l")
    end, {})
end

return M
