local M = {}

M.setup = function()
    -- set mapleader to space
    vim.g.mapleader = " "
    vim.g.maplocalleader = ";"

    -- Get rid of highlight after search
    vim.keymap.set("n", "<esc>", function()
        vim.cmd.noh()
    end, { silent = true, desc = "Remove Highlighted Searches" })

    -- Spell Checking
    vim.keymap.set("n", "<leader>st", function()
        vim.opt.spell = not vim.opt.spell:get()
    end, { silent = true, desc = "Toggle Spell" })

    -- Better split movement
    vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
    vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
    vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
    vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })

    -- Set current focused file as cwd
    vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>", { silent = true, desc = "Change CWD to Current File" })

    vim.keymap.set("n", "<leader>lh", function()
        if vim.diagnostic.is_disabled() then
            vim.diagnostic.enable()
        else
            vim.diagnostic.disable()
        end
    end, { silent = true, desc = "LSP: Toggle Diagnostics" })

    -- Toggle showing command bar
    vim.keymap.set("n", "<leader>sc", function()
        local current_cmdheight = vim.opt.cmdheight:get()
        if current_cmdheight > 0 then
            vim.opt.cmdheight = 0
        else
            vim.opt.cmdheight = 1
        end
    end, { silent = true, desc = "Toggle Cmdline" })

    -- Toggle relativenumber
    vim.keymap.set("n", "<leader>sn", function()
        vim.opt.relativenumber = not vim.opt.relativenumber:get()
    end, { silent = true, desc = "Toggle Relativenumber" })

    -- Sudo Write
    vim.keymap.set("c", "w!!", "w !sudo tee > /dev/null %", { silent = true, desc = "Write as Sudo" })

    -- Terminal mappings
    vim.keymap.set("t", [[<C-\>]], [[<C-\><C-n>]], { silent = true })

    -- Alternative bindings for increment & decrement
    vim.keymap.set("n", "+", "<C-a>", { silent = true, remap = true, desc = "Increment" })
    vim.keymap.set("n", "-", "<C-x>", { silent = true, remap = true, desc = "Decrement" })

    -- Tabclose binding
    vim.keymap.set("n", "<C-w>t", "<cmd>tabclose<CR>", { silent = true, desc = "Close Tab" })

    -- Buffer bindings
    vim.keymap.set("n", "<A-a>", ":bprevious<CR>", { silent = true, desc = "Go to Previous Buffer" })
    vim.keymap.set("n", "<A-s>", ":bnext<CR>", { silent = true, desc = "Go to Next Buffer" })

    -- Binding to insert literal tab
    vim.keymap.set("i", "<S-Tab>", function()
        if vim.opt_local.expandtab:get() then
            vim.api.nvim_feedkeys("\t", "m", false)
        else
            local spaces = string.rep(" ", vim.opt_local.shiftwidth:get() or 4)
            vim.api.nvim_feedkeys(spaces, "m", false)
        end
    end, { silent = true, desc = "Insert Literal Tab" })
end

return M
