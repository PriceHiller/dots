-- TODO: Make this more general, this will support my own NixOS config and dot file
-- stuff, but not generally usable for other projects. Would be good to use something
-- like `.nvim.lua` for this or whatever else works 🤷.

local original_diag_set = vim.diagnostic.set

---@param namespace integer The diagnostic namespace
---@param bufnr integer Buffer number
---@param diagnostics vim.Diagnostic.Set[]
---@param opts? vim.diagnostic.Opts Display options to pass to |vim.diagnostic.show()|
---@diagnostic disable-next-line: duplicate-set-field
vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
    ---@type vim.Diagnostic.Set[]
    local diags = {}
    for _, diag in ipairs(diagnostics) do
        -- I prefer using builtins via `builtins.`, not just using em' straight up as nixpkgs
        -- redefines them and I want to know exactly what I'm using
        if
            not vim.list_contains({
                "sema-primop-overridden",
                "sema-primop-removed-prefix",
            }, diag.user_data.lsp.code)
        then
            table.insert(diags, diag)
        end
    end

    original_diag_set(namespace, bufnr, diags, opts)
end

return {
    cmd = { "nixd" },
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "nixfmt" },
            },
            options = {
                nixos = {
                    expr = "(let pkgs = import <nixpkgs> { }; in (pkgs.lib.evalModules { modules = (import <nixpkgs/nixos/modules/module-list.nix>) ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options",
                },
                home_manager = {
                    expr = "(let pkgs = import <nixpkgs> { }; lib = import <home-manager/modules/lib/stdlib-extended.nix> pkgs.lib; in (lib.evalModules { modules = (import <home-manager/modules/modules.nix>) { inherit lib pkgs; check = false; }; })).options",
                },
            },
        },
    },
}
