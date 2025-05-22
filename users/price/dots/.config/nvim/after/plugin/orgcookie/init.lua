local org = require("orgmode")

---@class OrgCookieWatcher Updates Headline Cookies for Progress using Virtual Text
---@field private bufnr integer Buffer Watcher is attached to
---@field private attached boolean Whether the watcher is running
---@field private ns_id integer
local OrgCookieWatcher = {
    ns_id = vim.api.nvim_create_namespace("orgmode.ui.cookie"),
}

---@alias OrgCookieWatchers table<integer, OrgCookieWatcher> A mapping of buffer ids to watchers

---@type OrgCookieWatchers
local watchers = {}

---Get all currently registered cookie watchers
---@return OrgCookieWatchers
function OrgCookieWatcher.watchers()
    return watchers
end

---Gets an existing OrgCookieWatcher for the given buffer if it exists
---@param bufnr? integer Buffer to get the watcher for
---@return OrgCookieWatcher?
function OrgCookieWatcher.get(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local watcher = OrgCookieWatcher.watchers()[bufnr]
    return watcher
end

---Creates a new headline watcher
---@param bufnr? integer Buffer to watch, if unspecified then uses the current buffer
function OrgCookieWatcher.new(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local watcher = OrgCookieWatcher.get(bufnr)
    if watcher then
        return watcher
    end
    local this = setmetatable({
        bufnr = bufnr,
        attached = false,
    }, { __index = OrgCookieWatcher })
    watchers[this.bufnr] = this
    return watchers[this.bufnr]
end

---@param headline OrgHeadline
---@return OrgHeadline[]
function OrgCookieWatcher._parent_headlines(headline)
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

---@param start_line integer 0-indexed inclusive
---@param end_line integer 0-indexed inclusive
function OrgCookieWatcher:_del_extmarks(start_line, end_line)
    -- This gets us the last column of the line, we want to get all the extmarks from the first
    -- column (0th column) to the very last column of the given range
    local end_col = vim.fn.col({ end_line + 1, "$" })

    local old_extmarks = vim.api.nvim_buf_get_extmarks(
        self.bufnr,
        self.ns_id,
        { start_line, 0 },
        { end_line, end_col - 1 },
        { type = "virt_text", overlap = true }
    )
    for _, ext in ipairs(old_extmarks) do
        vim.api.nvim_buf_del_extmark(self.bufnr, self.ns_id, ext[1])
    end
end

---@param headline OrgHeadline
function OrgCookieWatcher:_set_cookie(headline)
    local cookie = headline:get_cookie()
    if not cookie then
        local headline_ln = headline:node():start()
        -- In the scenario where we are missing a cookie we want to make sure we've invalidated the
        -- old extmarks if they exist
        self:_del_extmarks(headline_ln, headline_ln)
        return
    end

    -- We preference checkboxes for the count, then todos, and if we have neither but still have a
    -- cookie then we want to show an indication of missing items
    local counts = self._get_checkbox_num(headline) or self._get_todo_num(headline) or { 0, 0 }

    local complete = counts[1]
    local total = counts[2]

    ---@type [string, string]
    local virt_text = {}

    -- Now we build up our virtual cookie
    table.insert(virt_text, { "[", "@org.cookie.delimiter.left" })
    if total == 0 then
        -- If we have no items to calculate the cookie based on, we want to represent that
        table.insert(virt_text, { "???", "@org.cookie.sign.unknown" })
    elseif headline.file:get_node_text(cookie):find("%%") then
        -- Handling a percentage cookie, e.g. [90%]
        local num = ("%.0f"):format(((complete / total) * 100))
        table.insert(virt_text, { num, "@org.cookie.num" })
        table.insert(virt_text, { "%", "@org.cookie.sign.percent" })
    else
        -- Handling an out of cookie, e.g. [10/12]
        table.insert(virt_text, { tostring(complete), "@org.cookie.num.complete" })
        table.insert(virt_text, { "/", "@org.cookie.sign.div" })
        table.insert(virt_text, { tostring(total), "@org.cookie.num.total" })
    end
    table.insert(virt_text, { "]", "@org.cookie.delimiter.right" })

    local line, start_col, _ = cookie:start()
    local end_line, end_col, _ = cookie:end_()

    -- Ensure we wipe out the old extmark before setting the new one.
    self:_del_extmarks(line, end_line)

    -- The virtual cookie text we put in place
    vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, line, start_col, {
        virt_text_pos = "inline",
        hl_mode = "combine",
        priority = 200,
        virt_text = virt_text,
    })

    -- This ensures the user can see the _actual_ cookie as well as the virtual cookie when relevant
    vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, line, start_col, {
        hl_mode = "combine",
        end_col = end_col,
        conceal = "",
    })
end

---@param headline OrgHeadline
---@return [integer, integer]?
function OrgCookieWatcher._get_checkbox_num(headline)
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
function OrgCookieWatcher._get_todo_num(headline)
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

---@param start_line integer 0-index row to start from
---@param end_line integer 0-index row to end at
function OrgCookieWatcher:_update_cookies_in_range(start_line, end_line)
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
        self:_set_cookie(headline)
        local parents = OrgCookieWatcher._parent_headlines(headline)
        for _, parent in ipairs(parents) do
            self:_set_cookie(parent)
        end
    end
end

---Get whether the watcher is currently attached
---@return boolean
function OrgCookieWatcher:is_attached()
    return self.attached
end

---Get the registered buffer id for the watcher
---@return integer
function OrgCookieWatcher:get_bufnr()
    return self.bufnr
end

---Starts the watcher for the watcher's buffer if it's not already attached
function OrgCookieWatcher:attach()
    if self.attached then
        return
    end
    self.attached = true

    watchers[self.bufnr] = self
    self:_update_cookies_in_range(0, vim.api.nvim_buf_line_count(self.bufnr) - 1)

    -- We cant use  `nvim_set_decoration_provider()` here because of a
    -- `org.files.get_closest_headline` call made later "modifies" (reloads) some content which
    -- causes the decoration provider to explode.
    --
    -- There's a way around this by playing entirely with the TS Nodes, but this seems fast enough
    -- so it'll do.
    vim.api.nvim_buf_attach(self.bufnr, false, {
        on_lines = function(_, _, _, start_line, _, end_line)
            if not self.attached then
                return true
            end

            vim.schedule(function()
                if start_line > 0 then
                    -- Sometimes we miss the outer range, so we want to ensure we grab that in those
                    -- scenarios
                    start_line = start_line - 1
                end
                self:_update_cookies_in_range(start_line, end_line)
            end)
        end,
        on_reload = function()
            self:_update_cookies_in_range(0, vim.api.nvim_buf_line_count(self.bufnr) - 1)
        end,
        on_detach = function()
            self:delete()
        end,
    })
end

---Detaches the watcher if it's attached
function OrgCookieWatcher:detach()
    if not self.attached then
        return
    end
    self.attached = false
    self:_del_extmarks(0, vim.api.nvim_buf_line_count(self.bufnr) - 1)
end

---Toggles the attached state for the watcher
function OrgCookieWatcher:toggle()
    if self.attached then
        self:detach()
    else
        self:attach()
    end
end

---Completely removes the watcher, including from tracked watchers
function OrgCookieWatcher:delete()
    self:detach()
    watchers[self.bufnr] = nil
end

-- We only want to create the autocmds for registering watchers once
local ft_autocmd_created = false
if not ft_autocmd_created then
    ft_autocmd_created = true

    -- We want to create and attach a new watcher for every buffer
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "org",
        callback = function(args)
            local watcher = OrgCookieWatcher.new(args.buf)
            watcher:attach()
        end,
    })

    -- Ensure we clean up invalid watchers
    vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(args)
            local watcher = OrgCookieWatcher.get(args.buf)
            if watcher then
                watcher:delete()
            end
        end,
    })
end

return OrgCookieWatcher
