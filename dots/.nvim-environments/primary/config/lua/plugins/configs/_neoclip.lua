local loaded, neoclip = pcall(require, "neoclip")
if not loaded then
    return
end
neoclip.setup({
    enable_persistent_history = true,
})
