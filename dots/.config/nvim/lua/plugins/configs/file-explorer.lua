local nvim_tree = require("nvim-tree.configs")

nvim_tree.setup({
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        disable = {
            -- Ansible support reasons
            "ansible.yaml",
            "yaml.ansible",
        },
    },
    matchup = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
})
