-- NOTE: ANSIBLE LSP
-- I use ansible a lot, define exceptions for servers that can use
-- server:setup & vim.cmd at the bottom here
return {
    settings = {
        ansible = {
            ansible = {
                useFullyQualifiedCollectionNames = true,
                path = "ansible",
            },
            ansibleLint = {
                enabled = true,
                path = "ansible-lint",
            },
            python = {
                interpreterPath = "python3",
            },
            completion = {
                provideRedirectModules = true,
            },
        },
    },
}
