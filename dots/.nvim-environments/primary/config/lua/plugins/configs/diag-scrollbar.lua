local loaded, colors = pcall(require, "kanagawa.colors")
if not loaded then
    return
end
local loaded, scrollbar = pcall(require, "scrollbar")
if not loaded then
    return
end

scrollbar.setup({
    handle = {
        color = colors.bg_highlight,
    },
    marks = {
        Search = { color = colors.orange },
        Error = { color = colors.error },
        Warn = { color = colors.warning },
        Info = { color = colors.info },
        Hint = { color = colors.hint },
        Misc = { color = colors.purple },
    },
    handlers = {
        diagnostic = true,
        search = true,
    },
})
