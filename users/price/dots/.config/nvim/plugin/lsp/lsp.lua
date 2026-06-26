-- Enable lsp on type formatting for all clients by default
if vim.lsp.on_type_formatting then
    vim.lsp.on_type_formatting.enable()
end

-- Enable lsp inlay hints on all clients by default
vim.lsp.inlay_hint.enable(true)
