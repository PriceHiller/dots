local M = {}

M.setup = function()
    -- set mapleader to space
    vim.g.mapleader = " "

    -- Get rid of highlight after search
    vim.keymap.set("n", "<esc>", ":noh<CR>")

    -- Spell Checking
    vim.keymap.set("n", "<leader>st", ":set spell!<CR>")

    -- Better split movement
    vim.keymap.set("n", "<C-l>", "<C-w>l")
    vim.keymap.set("n", "<C-h>", "<C-w>h")
    vim.keymap.set("n", "<C-k>", "<C-w>k")
    vim.keymap.set("n", "<C-j>", "<C-w>j")

    -- Better split closing
    vim.keymap.set("n", "<C-x>", "<C-w>c")

    -- Set current focused file as cwd
    vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>")

    -- Toggle showing diagnostics
    local diagnostics_active = true
    vim.keymap.set("n", "<leader>lh", function()
        diagnostics_active = not diagnostics_active
        if diagnostics_active then
            vim.diagnostic.enable()
        else
            vim.diagnostic.disable()
        end
    end, { desc = "Toggle Diagnostics" })

    -- Toggle showing command bar
    vim.keymap.set("n", "<leader>cl", function()
        local current_cmdheight = vim.opt.cmdheight:get()
        if current_cmdheight > 0 then
            vim.opt.cmdheight = 0
        else
            vim.opt.cmdheight = 1
        end
    end, { desc = "Toggle Cmdline" })

    -- Toggle relativenumber
    vim.keymap.set("n", "<leader>sn", function()
        vim.opt.relativenumber = not vim.opt.relativenumber:get()
    end, { desc = "Toggle Relativenumber" })

    -- Sudo Write
    vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %")

    -- Terminal mappings
    vim.keymap.set("t", [[<C-\>]], [[<C-\><C-n>]])
end

return M
