local loaded, nvim_treesitter = pcall(require, "nvim-treesitter.configs")
if not loaded then
    return
end

nvim_treesitter.setup({
    ensure_installed = {
        "norg",
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        disable = { "yaml" },
    },
    matchup = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
    yati = {
        enable = true,
    },
})
