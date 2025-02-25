return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")
            local cond = require("nvim-autopairs.conds")
            npairs.setup()

            npairs.add_rules({
                Rule("~", "~", { "org" }),
                Rule("*", "*", { "org" }):with_pair(cond.not_before_regex("^$")):with_pair(cond.not_before_regex("%*")),
                Rule("/", "/", { "org" }):with_pair(cond.not_before_regex("%[")):with_pair(cond.not_before_regex("%]")),
                Rule("_", "_", { "org" }),
                Rule("=", "=", { "org" }),
                Rule("$", "$", { "org" }),
            })

            npairs.add_rules({
                Rule("_", "_", { "markdown" }),
                Rule("*", "*", { "markdown" }):with_pair(cond.not_before_regex("^$")),
                Rule("$", "$", { "markdown" }),
            })
        end,
    },
}
