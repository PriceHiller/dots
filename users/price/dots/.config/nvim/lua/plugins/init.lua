local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.notify("Installing Lazy plugin manager, please wait...")
    local status = vim.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    }):wait()

    if status.code > 0 then
        error(
            "Failed to install lazy.nvim!\n====STDOUT====\n" .. status.stdout .. "\n====STDERR====\n" .. status.stderr
        )
    end
end
vim.opt.runtimepath:prepend(lazypath)

local lazy = require("lazy")

lazy.setup("plugins.configs", {
    defaults = {
        version = false,
        lazy = false,
    },
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

require("plugins.autocmds")
require("plugins.postload")
