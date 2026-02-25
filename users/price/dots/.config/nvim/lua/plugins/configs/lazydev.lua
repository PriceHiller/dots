return {
    {
        "folke/lazydev.nvim",
        cmd = "LazyDev",
        ft = "lua",
        init = function()
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        workspace = {
                            library = {
                                -- HACK: Ensure lazydev is loaded to pick up Neovim runtime
                                -- see https://github.com/folke/lazydev.nvim/issues/136
                                vim.api.nvim_get_runtime_file("", true),
                            },
                        },
                    },
                },
            })
        end,
        opts = {
            library = {
                "lazy.nvim",
                { path = "luassert-types/library", words = { "assert" } },
                { path = "busted-types/library", words = { "describe" } },
                { path = "${3rd}/luv/library", words = { "vim%.uv", "vim%.loop" } },
                { path = "wezterm-types", mods = { "wezterm" } },
            },
        },
        dependencies = {
            { "LuaCATS/luassert", lazy = true },
            { "LuaCATS/busted", lazy = true },
            { "gonstoll/wezterm-types", lazy = true },
        },
    },
}
