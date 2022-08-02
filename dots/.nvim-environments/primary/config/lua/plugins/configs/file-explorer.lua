local loaded, nvim_tree = pcall(require, "nvim-tree.configs")
if not loaded then
    return
end

nvim_tree.setup({
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        disable = {
            -- Ansible support reasons
            "ansible.yaml",
        },
    },
    matchup = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
})
