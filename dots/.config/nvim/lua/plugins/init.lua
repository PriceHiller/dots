local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.notify("Installing Lazy plugin manager, please wait...")
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

local lazy = require("lazy")

lazy.setup("plugins.configs", {
    defaults = {
        version = false,
        lazy = false,
    },
    colorscheme = function()
        vim.cmd.colorscheme("kanagawa")
        vim.notify("WTF!")
    end,
    checker = {
        enabled = true,
        concurrency = 20,
        notify = false,
    },
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
    dev = {
        path = "~/Git/Neovim",
    },
    install = {
        missing = true,
        colorscheme = { "kanagawa" },
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
