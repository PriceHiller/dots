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
function OrgCookieWatcher:_get_extmarks(start_line, end_line)
    -- This gets us the last column of the line, we want to get all the extmarks from the first
    -- column (0th column) to the very last column of the given range
    local end_col = vim.fn.col({ end_line + 1, "$" })

    return vim.api.nvim_buf_get_extmarks(
        self.bufnr,
        self.ns_id,
        { start_line, 0 },
        { end_line, end_col - 1 },
        { overlap = true }
    )
end

---@param start_line integer 0-indexed inclusive
---@param end_line integer 0-indexed inclusive
function OrgCookieWatcher:_del_extmarks(start_line, end_line)
    vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, start_line, end_line + 1)
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
    ---@type [integer, integer]
    local counts = self._get_checkbox_num(headline) or self._get_todo_num(headline) or {}

    ---@type integer?
    local complete = counts[1]
    ---@type integer?
    local total = counts[2]

    ---@type [string, string][]
    local virt_text = {}

    -- Now we build up our virtual cookie
    table.insert(virt_text, { "[", "@org.cookie.delimiter.left" })
    local cur_cookie_text = vim.treesitter.get_node_text(cookie, self.bufnr, {})
    if cur_cookie_text:find("%%") then
        -- Handling a percentage cookie, e.g. [90%]
        if total and complete then
            local num = ("%.0f"):format(((complete / total) * 100))
            table.insert(virt_text, { num, "@org.cookie.num" })
        end
        table.insert(virt_text, { "%", "@org.cookie.sign.percent" })
    else
        -- Handling an out of cookie, e.g. [10/12]
        if complete then
            table.insert(virt_text, { tostring(complete), "@org.cookie.num.complete" })
        end
        table.insert(virt_text, { "/", "@org.cookie.sign.div" })
        if total then
            table.insert(virt_text, { tostring(total), "@org.cookie.num.total" })
        end
    end
    table.insert(virt_text, { "]", "@org.cookie.delimiter.right" })

    local line, start_col, _ = cookie:start()
    local end_line, end_col, _ = cookie:end_()

    ---@type [string, integer, integer][]
    local hl_ranges = {}
    local cookie_parts = {}
    local hl_col_start = start_col
    for _, vt in pairs(virt_text) do
        local text, hl = vt[1], vt[2]
        local hl_col_end = hl_col_start + #text
        table.insert(hl_ranges, { hl, hl_col_start, hl_col_end })
        hl_col_start = hl_col_end
        table.insert(cookie_parts, text)
    end
    local new_cookie_text = table.concat(cookie_parts, "")

    local update_hls = function()
        self:_del_extmarks(line, end_line)
        for _, hl_range in pairs(hl_ranges) do
            local hl, start_hl_col, end_hl_col = unpack(hl_range)
            vim.hl.range(self.bufnr, self.ns_id, hl, { line, start_hl_col }, { line, end_hl_col }, {})
        end
    end

    -- Only update the text if we have a difference AND we have valid progress (not 0/0) to show
    local undotree = vim.fn.undotree(self.bufnr)
    local after_undo = undotree.seq_cur ~= undotree.seq_last
    local try_restore_cursor = function()
        -- Try to restore the cursor position when we're undoing a change that triggered a
        -- modification of the cookie
        if after_undo then
            local row, col = unpack(vim.api.nvim_buf_get_mark(self.bufnr, "."))
            row = row - 1

            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_get_buf(win) == self.bufnr then
                pcall(vim.api.nvim_win_set_cursor, win, { row, col })
            end
            return
        end
    end

    if cur_cookie_text == new_cookie_text then
        update_hls()
        try_restore_cursor()
        return
    end

    if after_undo then
        try_restore_cursor()
        return
    end
    --
    -- We don't want to update any cookie text if our `undotree` isn't "safe". We have to call
    -- `undojoin` later on to ensure we don't mangle the `undotree` with the text updates made to
    -- the cookies. If our `undotree` is in an unsafe state (i.e. can't use `undojoin` safely in the
    -- current context), then we necessarily don't want to issue any updates.
    _G._tmp_orgcookie_update_cookie = function()
        vim.cmd.undojoin()
        vim.api.nvim_buf_set_text(self.bufnr, line, start_col, line, end_col, { new_cookie_text })
        update_hls()
    end
    vim.api.nvim_cmd({
        cmd = "lua",
        args = {
            "_G._tmp_orgcookie_update_cookie()",
        },
        mods = {
            keeppatterns = true,
            lockmarks = true,
            keepmarks = true,
            keepjumps = true,
        },
    }, {})
    _G._tmp_orgcookie_update_cookie = nil
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
                local checked_boxes = vim.tbl_filter(function(box)
                    num_boxes = num_boxes + 1
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
    local updating = false
    local last_start_line = -1
    local last_end_line = -1
    vim.api.nvim_buf_attach(self.bufnr, false, {
        on_lines = function(_, _, _, start_line, _, end_line)
            if not self.attached then
                return true
            end

            if start_line == last_start_line and end_line == last_end_line and updating then
                return
            end
            last_start_line = start_line
            last_end_line = end_line
            updating = true

            vim.schedule(function()
                if start_line > 0 then
                    -- Sometimes we miss the outer range, so we want to ensure we grab that in those
                    -- scenarios
                    start_line = start_line - 1
                end
                self:_update_cookies_in_range(start_line, end_line)

                -- BUG: There's a possible bug that might rear its ugly head here. We have a
                -- crapalicious guard around this critical section (see if the `if` checks above
                -- combined with checking `updating`). We only want to update the cookies in the
                -- given range if we're not currently updating _OR_ the start or end lines differ
                -- from the previous update while we have a currently running update. Since we
                -- choose to defer here, there's a small gap where `updating` can be set to false
                -- despite a new update being started leading to an extra update slipping through
                -- the cracks when it really shouldn't have been run.
                --
                -- TODO: This can possibly be fixed using a queue system that gathers up the changes
                -- in a fixed interval and then runs all the updates for the gathered ranges at once
                -- in a single job.
                updating = false
                -- vim.defer_fn(function()
                -- end, 20)
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
