return {
    {
        "3rd/image.nvim",
        build = function()
            ---@type vim.SystemCompleted
            local out = vim.system({ "luarocks", "--lua-version", "5.1", "--local", "install", "magick" }):wait()
            if out.code ~= 0 then
                error(
                string.format(
                "Failed to install `magick` luarock for image.nvim!\n---STDOUT---\n%s\n\n---STDERR---\n\n%s", out.stdout,
                    out.stderr), vim.log.levels.ERROR)
            end
        end,
        ft = { "markdown", "norg" },
        config = function()
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
            require("image").setup({})
            vim.cmd.edit()
        end,
    },
}
