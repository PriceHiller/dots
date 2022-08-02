require('plugins.plugins')
local found, _ = pcall(require, 'packer_compiled')
if not found then
    vim.notify('Unable to locate packer_compiled!')
end
