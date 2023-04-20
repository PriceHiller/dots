local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.shfmt.with({
            extra_args = { "-i 4" },
        }),
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
    },
})
