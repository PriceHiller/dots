vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.textwidth = 0

vim.keymap.set("n", "<localleader>fr", "<cmd>GithubPreviewToggle<CR>", {
    buffer = true,
    desc = "Preview Markdown in Browser",
})

local markview = require("markview")
vim.keymap.set("n", "<leader>ff", function()
    markview.state.hybrid_mode = not markview.state.hybrid_mode
    local hybrid_state = markview.state.hybrid_mode and "Enabled" or "Disabled"
    vim.notify(("%s Markview Hybrid Mode"):format(hybrid_state), vim.log.levels.INFO, { title = "Markview" })
end, {
    buffer = true,
    desc = "Toggle Markview Hybrid Mode",
})

vim.keymap.set("n", "<leader>ft", function()
    vim.cmd("Markview toggle")
    local mview_state = markview.state.enable and "Enabled" or "Disabled"
    vim.notify(("Markview %s"):format(mview_state), vim.log.levels.INFO, { title = "Markview" })
end, {
    buffer = true,
    desc = "Toggle Markview",
})

vim.keymap.set("n", "<C-Space>", function()
    local cur_line = vim.fn.line(".")
    local line_text = vim.fn.getline(".")
    local lead, char, task = line_text:match("^(%s*- )%[(.)%](.*)")
    local new_char
    if char == " " then
        new_char = "x"
    elseif char == "x" then
        new_char = " "
    end

    if new_char then
        local updated_task_str = lead .. "[" .. new_char .. "]" .. task
        vim.api.nvim_buf_set_lines(0, cur_line - 1, cur_line, true, { updated_task_str })
    end
end, { buffer = true })

vim.opt.formatlistpat = [[^\s*\(-\|\d\+\.|+\|>\)\s*]]
