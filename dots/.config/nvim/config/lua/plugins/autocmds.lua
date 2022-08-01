vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function()
        local filetype = vim.bo.filetype
        local neoformat_types = { 'sh' }
        local ignore_types = { 'sql' }

        for _, ig_type in ipairs(ignore_types) do
            if filetype == ig_type then
                return
            end
        end

        for _, nf_type in ipairs(neoformat_types) do
            if filetype == nf_type then
                vim.cmd('Neoformat')
                return
            end
        end

        vim.cmd('lua vim.lsp.buf.format({})')
    end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '**/nvim/lua/plugins/plugins.lua',
    callback = function()
        vim.notify('Compiling Packer')
        require('packer').compile()
    end,
})
