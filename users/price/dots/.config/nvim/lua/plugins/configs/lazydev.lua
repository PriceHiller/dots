return {
    {
        "folke/lazydev.nvim",
        cmd = "LazyDev",
        ft = "lua",
        opts = {
            library = {
                "lazy.nvim",
                { path = "luassert-types/library", words = { "assert" } },
                { path = "busted-types/library", words = { "describe" } },
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
        config = function(_, opts)
            local lsp = require("lazydev.lsp")
            local Workspace = require("lazydev.workspace")
            local original = lsp.on_workspace_configuration

            -- Shim in a proper compatability bridge for emmylua so lazydev can correctly apply
            -- settings to emmylua_ls
            lsp.on_workspace_configuration = function(err, params, ctx, cfg)
                local response = original(err, params, ctx, cfg)
                local client = vim.lsp.get_client_by_id(ctx.client_id)

                if not client or client.name ~= "emmylua_ls" then
                    return response
                end

                for i, item in ipairs(params.items or {}) do
                    if item.section == "emmylua" then
                        local ws = item.scopeUri and Workspace.get(client, vim.uri_to_fname(item.scopeUri))
                            or Workspace.single(client)
                        local discovered = vim.tbl_get(ws.settings, "Lua", "workspace", "library")

                        if ws:enabled() and discovered then
                            local settings = vim.deepcopy(client.settings.emmylua or {})
                            local library = vim.tbl_get(settings, "workspace", "library") or {}

                            for _, path in ipairs(discovered) do
                                if not vim.list_contains(library, path) then
                                    table.insert(library, path)
                                end
                            end

                            settings.workspace = settings.workspace or {}
                            settings.workspace.library = library
                            response[i] = settings
                        end
                    end
                end

                return response
            end

            require("lazydev").setup(opts)
        end,
        dependencies = {
            { "LuaCATS/luassert", lazy = true },
            { "LuaCATS/busted", lazy = true },
            { "DrKJeff16/wezterm-types", lazy = true },
        },
    },
}
