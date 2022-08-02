local loaded, fidget = pcall(require, "fidget")
if not loaded then
    return
end

fidget.setup({
    text = {
        spinner = "dots",
    },
    window = {
        blend = 0,
    },
})
