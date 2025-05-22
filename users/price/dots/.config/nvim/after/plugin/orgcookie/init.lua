local org = require("orgmode")

---@class OrgHeadlineWatcher
---@field private bufnr integer Buffer Watcher is attached to
---@field private attached boolean Whether the watcher is running
---@field private updating boolean
---@field private timer uv.uv_timer_t
---@field private ns_id integer
local HeadlineWatcher = {
    ns_id = vim.api.nvim_create_namespace("orgmode.ui.cookie"),
}

---@type table<integer, OrgHeadlineWatcher>
local watchers = {}

---@return table<integer, OrgHeadlineWatcher>
function HeadlineWatcher.watchers()
    return watchers
end

--- Creates a new headline watcher
---@param bufnr? integer Buffer to watch, if unspecified then uses the current buffer
function HeadlineWatcher.new(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local watcher = HeadlineWatcher.watchers()[bufnr]
    if watcher then
        return watcher
    end
    local this = setmetatable({
        bufnr = bufnr,
        attached = false,
        updating = false,
    }, { __index = HeadlineWatcher })
    watchers[this.bufnr] = this
    return watchers[this.bufnr]
end

---@param headline OrgHeadline
---@return OrgHeadline[]
function HeadlineWatcher.parent_headlines(headline)
    local located_headlines = {}
    local count = 0
    while true do
        count = count + 1
        local parent = headline:get_parent_headline()

        if not parent or not parent.headline then
            break
        end

        table.insert(located_headlines, parent)
        headline = parent
    end
    return located_headlines
end

---@param start_line integer
---@param end_line integer
function HeadlineWatcher:del_extmarks(start_line, end_line)
    local old_extmarks = vim.api.nvim_buf_get_extmarks(
        self.bufnr,
        self.ns_id,
        start_line,
        end_line,
        { type = "virt_text", overlap = true }
    )
    for _, ext in ipairs(old_extmarks) do
        vim.api.nvim_buf_del_extmark(self.bufnr, self.ns_id, ext[1])
    end
end

---@param headline OrgHeadline
function HeadlineWatcher:set_cookie(headline)
    local cookie = headline:get_cookie()
    if not cookie then
        return
    end

    local counts = self.get_checkbox_num(headline) or self.get_todo_num(headline)
    if not counts then
        return
    end

    local complete = counts[1]
    local total = counts[2]

    local text = {
        { "[", "@org.cookie.delimiter.left" },
    }
    if headline.file:get_node_text(cookie):find("%%") then
        local num = tostring(((complete / total) * 100))
        table.insert(text, { num, "@org.cookie.num" })
        table.insert(text, { "%", "@org.cookie.sign.percent" })
    else
        table.insert(text, { tostring(complete), "@org.cookie.num.complete" })
        table.insert(text, { "/", "@org.cookie.sign.div" })
        table.insert(text, { tostring(total), "@org.cookie.num.total" })
    end

    table.insert(text, { "]", "@org.cookie.delimiter.right" })

    local line, start_col, _ = cookie:start()
    self:del_extmarks(line - 1, line)

    vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, line, start_col, {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 200,
        virt_text = text,
    })
end

---@param headline OrgHeadline
---@return [integer, integer]?
function HeadlineWatcher.get_checkbox_num(headline)
    local section = headline:node():parent()
    if not section then
        return nil
    end

    -- Count checked boxes from all lists
    local num_checked_boxes, num_boxes = 0, 0
    local body = section:field("body")[1]
    if body then
        for node in body:iter_children() do
            if node:type() == "list" then
                local boxes = headline:child_checkboxes(node)
                num_boxes = num_boxes + #boxes
                local checked_boxes = vim.tbl_filter(function(box)
                    return box:match("%[%w%]")
                end, boxes)
                num_checked_boxes = num_checked_boxes + #checked_boxes
            end
        end
    end

    if num_boxes == 0 then
        return nil
    end

    return { num_checked_boxes, num_boxes }
end

---@param headline OrgHeadline
---@return [integer, integer]?
function HeadlineWatcher.get_todo_num(headline)
    -- Count done children headlines and total children with TODO keywords
    local children = headline:get_child_headlines()
    local headlines_with_todo = vim.tbl_filter(function(h)
        local todo, _, _ = h:get_todo()
        return todo ~= nil
    end, children)

    if #headlines_with_todo == 0 then
        return nil
    end

    local dones = vim.tbl_filter(function(h)
        return h:is_done()
    end, headlines_with_todo)

    return { #dones, #headlines_with_todo }
end

---@param headline OrgHeadline
function HeadlineWatcher.update_cookies(headline)
    if not headline:get_cookie() then
        return
    end
    local has_todos = false
    for _, ch in ipairs(headline:get_child_headlines()) do
        local todo, _, _ = ch:get_todo()
        if todo then
            has_todos = true
            break
        end
    end

    if has_todos then
        headline:update_todo_cookie()
    else
        headline:update_cookie()
    end
end

---@param start_line integer 0-index row to start from
---@param end_line integer 0-index row to end at
function HeadlineWatcher:update_cookies_in_range(start_line, end_line)
    ---@type table<integer, OrgHeadline>
    local modified_headlines = {}
    for line = start_line, end_line, 1 do
        local success, headline = pcall(org.files.get_closest_headline, org.files, { line + 1, 0 })
        if headline and success then
            local headline_row, _, _ = headline:node():start()
            modified_headlines[headline_row] = headline
        end
    end
    for _, headline in pairs(modified_headlines) do
        self:set_cookie(headline)
        local parents = HeadlineWatcher.parent_headlines(headline)
        for _, parent in ipairs(parents) do
            self:set_cookie(parent)
        end
    end
end

function HeadlineWatcher:attach()
    if self.attached then
        return
    end
    self.attached = true

    watchers[self.bufnr] = self
    self:update_cookies_in_range(0, vim.api.nvim_buf_line_count(self.bufnr) - 1)

    vim.api.nvim_buf_attach(self.bufnr, false, {
        on_lines = function(_, _, _, start_line, _, end_line)
            if not self.attached then
                return true
            end

            vim.schedule(function()
                self:update_cookies_in_range(start_line, end_line)
            end)
        end,
        on_reload = function()
            self:update_cookies_in_range(0, vim.api.nvim_buf_line_count(self.bufnr) - 1)
        end,
        on_detach = function()
            self:delete()
        end,
    })
end

function HeadlineWatcher:detach()
    self.attached = false
    self:del_extmarks(0, vim.api.nvim_buf_line_count(self.bufnr) - 1)
end

function HeadlineWatcher:delete()
    self:detach()
    watchers[self.bufnr] = nil
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "org",
    callback = function(args)
        local watcher = HeadlineWatcher.new(args.buf)
        watcher:attach()
    end,
})

return HeadlineWatcher
