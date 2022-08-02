local loaded, colorizer = pcall(require, "colorizer")
if not loaded then
    return
end
colorizer.setup({})
vim.cmd("ColorizerAttachToBuffer")
