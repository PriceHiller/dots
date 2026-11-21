-- Disable conceal and Markdown rendering while native multicursors are present.
if vim.fn.exists("##CmdAtom") == 0 then
    return
end

local group = vim.api.nvim_create_augroup("MulticursorConceal", { clear = true })
local ns = vim.api.nvim_create_namespace("nvim.multicursor")

---@class MulticursorRenderMarkdown
---@field get fun(buf: integer): boolean
---@field buf_disable fun()
---@field buf_enable fun()

local saved ---@type { win: integer, buf: integer, level: integer, render_markdown: MulticursorRenderMarkdown? }?

local function restore()
    local previous = saved
    if not previous then
        return
    end
    saved = nil

    if vim.api.nvim_win_is_valid(previous.win) and vim.api.nvim_win_get_buf(previous.win) == previous.buf then
        vim.wo[previous.win][0].conceallevel = previous.level
    end
    if previous.render_markdown and vim.api.nvim_buf_is_valid(previous.buf) then
        vim.api.nvim_buf_call(previous.buf, previous.render_markdown.buf_enable)
    end
end

-- Restore before leaving or splitting so a split doesn't inherit the temporary level.
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "WinNewPre" }, {
    group = group,
    callback = restore,
})

-- CmdAtom sees completed user actions; SafeState also checks when Nvim goes idle after API changes.
vim.api.nvim_create_autocmd({ "CmdAtom", "SafeState" }, {
    group = group,
    desc = "Disable conceal while native multicursors are present",
    callback = function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        if saved and (saved.win ~= win or saved.buf ~= buf) then
            restore()
        end
        if #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { limit = 1 }) == 0 then
            restore()
            return
        end

        local opts = vim.wo[win][0]
        if not saved then
            saved = { win = win, buf = buf, level = opts.conceallevel }
        end

        -- Optional integration: never load RenderMarkdown ourselves.
        local render_markdown = package.loaded["render-markdown"] ---@type MulticursorRenderMarkdown?
        if render_markdown and render_markdown.get(buf) then
            saved.render_markdown = render_markdown
            render_markdown.buf_disable()
        end
        if opts.conceallevel ~= 0 then
            opts.conceallevel = 0
        end
    end,
})
