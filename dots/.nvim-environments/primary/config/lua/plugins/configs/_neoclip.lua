local neoclip = pcall(require, "neoclip")
if not neoclip then
    return
end
neoclip.setup({
    enable_persistent_history = true,
})
