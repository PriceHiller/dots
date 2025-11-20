-- Huge shoutout to https://github.com/joe-p, this was pulled from
-- https://github.com/joe-p/neovim-config/blob/c34aabe748145e0d9da7d5d3ec83da8d198d505d/lua/diagnostic.lua

-- Get the window id for a buffer
-- @param bufnr integer
local function buf_to_win(bufnr)
    local current_win = vim.fn.win_getid()

    -- Check if current window has the buffer
    if vim.fn.winbufnr(current_win) == bufnr then
        return current_win
    end

    -- Otherwise, find a visible window with this buffer
    local win_ids = vim.fn.win_findbuf(bufnr)
    local current_tabpage = vim.fn.tabpagenr()

    for _, win_id in ipairs(win_ids) do
        if vim.fn.win_id2tabwin(win_id)[1] == current_tabpage then
            return win_id
        end
    end

    return current_win
end

-- Split a string into multiple lines, each no longer than max_width
-- The split will only occur on spaces to preserve readability
-- @param str string
-- @param max_width integer
local function split_line(str, max_width)
    if #str <= max_width then
        return { str }
    end

    local lines = {}
    local current_line = ""

    for word in string.gmatch(str, "%S+") do
        -- If adding this word would exceed max_width
        if #current_line + #word + 1 > max_width then
            -- Add the current line to our results
            table.insert(lines, current_line)
            current_line = word
        else
            -- Add word to the current line with a space if needed
            if current_line ~= "" then
                current_line = current_line .. " " .. word
            else
                current_line = word
            end
        end
    end

    -- Don't forget the last line
    if current_line ~= "" then
        table.insert(lines, current_line)
    end

    return lines
end

---@class WrapDiag
---@field redraw_debounce integer
---@field augroup integer
local WrapDiag = {
    redraw_debounce = 50,
    augroup = vim.api.nvim_create_augroup("Wrap Diagnostics", {}),
}

---@param diagnostic vim.Diagnostic
---@return string?
function WrapDiag.virtual_lines_format(diagnostic)
    local win = buf_to_win(diagnostic.bufnr)
    local sign_column_width = vim.fn.getwininfo(win)[1].textoff
    local text_area_width = vim.api.nvim_win_get_width(win) - sign_column_width
    local center_width = 5
    local left_width = 1

    ---@type string[]
    local lines = {}
    for msg_line in diagnostic.message:gmatch("([^\n]+)") do
        local max_width = text_area_width - diagnostic.col - center_width - left_width
        vim.list_extend(lines, split_line(msg_line, max_width))
    end

    return table.concat(lines, "\n")
end

-- Don't show virtual text on current line since we'll show virtual_lines
---@param diagnostic vim.Diagnostic
---@return string?
function WrapDiag.virtual_text_format(diagnostic)
    local diag_cfg = vim.diagnostic.config()
    if not diag_cfg then
        return diagnostic.message
    end

    if diag_cfg and type(diag_cfg.virtual_lines) == "table" and not diag_cfg.virtual_lines.current_line then
        return nil
    end

    if vim.fn.line(".") == diagnostic.lnum + 1 then
        return nil
    end

    return diagnostic.message
end

---@return vim.diagnostic.Opts
function WrapDiag:get_default_diag_config()
    return {
        virtual_text = { format = self.virtual_text_format },
        virtual_lines = { format = self.virtual_lines_format, current_line = true },
    }
end

---@param opts vim.diagnostic.Opts?
function WrapDiag:set_diag_config(opts)
    local defaults = self:get_default_diag_config()
    opts = vim.tbl_deep_extend("force", defaults, opts or {})
    vim.diagnostic.config(opts)
end

function WrapDiag:refresh()
    vim.diagnostic.hide()
    vim.diagnostic.show()
end

---@class WrapDiagBufVars
---@field last_line integer?
local WrapDiagBufVars = {
    last_line = nil,
}

---@return WrapDiagBufVars
function WrapDiagBufVars.get()
    if not vim.b.wrapdiag then
        ---@type WrapDiagBufVars
        vim.b.wrapdiag = {}
    end
    return vim.b.wrapdiag
end

---@param vars WrapDiagBufVars
function WrapDiagBufVars.set(vars)
    if not vim.b.wrapdiag then
        vim.b.wrapdiag = {}
    end

    vim.b.wrapdiag = vim.tbl_deep_extend("force", vim.b.wrapdiag, vars)
end

-- Re-draw diagnostics each line change to account for virtual_text changes
function WrapDiag:setup()
    WrapDiag:set_diag_config()

    local timer = nil

    WrapDiagBufVars.set({
        last_line = vim.fn.line("."),
    })

    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        group = self.augroup,
        callback = function()
            local current_line = vim.fn.line(".")
            local vars = WrapDiagBufVars.get()

            if current_line ~= vars.last_line then
                -- Line changed - cancel any pending timer and start a new one
                if timer then
                    timer:stop()
                end

                timer = vim.defer_fn(function()
                    self:refresh()
                    WrapDiagBufVars.set({
                        last_line = current_line,
                    })
                end, self.redraw_debounce)
            end
            -- If same line, do nothing - let any existing timer continue
        end,
    })

    -- Re-render diagnostics when the window is resized
    vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
        group = self.augroup,
        callback = function()
            self:refresh()
        end,
    })
end

function WrapDiag:toggle_current_line()
    local diag_cfg = vim.diagnostic.config()
    if not diag_cfg then
        return
    end
    self:set_diag_config({
        virtual_lines = {
            current_line = not diag_cfg.virtual_lines.current_line,
        },
    })
end

return WrapDiag
