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
                { path = "nvim-lspconfig", words = { "lspconfig" } },
                {
                    path = (vim.env.HYPRLAND_LUA_STUBS_PATH or "/run/current-system/sw/share/hypr/stubs"),
                    words = { "hl%." },
                },
            },
            enabled = function(root_dir)
                local enabled_checks = {
                    function()
                        vim.g.lazydev_disabled_roots = vim.g.lazydev_disabled_roots or {}
                        return not vim.list_contains(vim.g.lazydev_disabled_roots, root_dir)
                    end,
                    function()
                        return vim.g.lazydev_enabled == nil or vim.g.lazydev_enabled
                    end,
                }

                for _, check in ipairs(enabled_checks) do
                    if not check() then
                        return false
                    end
                end

                return true
            end,
        },
        dependencies = {
            { "LuaCATS/luassert", lazy = true },
            { "LuaCATS/busted", lazy = true },
            { "DrKJeff16/wezterm-types", lazy = true },
        },
    },
}
