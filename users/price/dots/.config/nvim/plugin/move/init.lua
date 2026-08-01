--- Native reimplementation of the line-moving motions from
--- https://github.com/matze/vim-move.
---
--- For now this only covers moving the current line (or the visually
--- selected lines) up/down with <A-j>/<A-k>; the horizontal motions
--- (<A-h>/<A-l>) are intentionally not implemented.

--- Moves the lines between `first` and `last` (line number expressions, e.g.
--- "." or "'<") down if `distance` is positive and up if `distance` is
--- negative, then reindents the moved block. Leaves the cursor on the last
--- moved line.
---@param first string
---@param last string
---@param distance integer
local function move_vertically(first, last, distance)
    if not vim.bo.modifiable or distance == 0 then
        return
    end

    local first_line = vim.fn.line(first)
    local last_line = vim.fn.line(last)

    -- Move the cursor with `j`/`k` (rather than just adding to the line
    -- number) so the destination is clamped to the buffer bounds and skips
    -- over closed folds.
    local old_pos = vim.fn.getcurpos()
    local after
    if distance < 0 then
        vim.fn.cursor(first_line, 1)
        vim.cmd("normal! " .. -distance .. "k")
        after = vim.fn.line(".") - 1
    else
        vim.fn.cursor(last_line, 1)
        vim.cmd("normal! " .. distance .. "j")
        local foldend = vim.fn.foldclosedend(".")
        after = (foldend == -1) and vim.fn.line(".") or foldend
    end

    -- Restoring the cursor prevents undoing a move across a folded section
    -- from unfolding it.
    vim.fn.setpos(".", old_pos)

    -- Join with the previous undo step if it was also a move in the same
    -- direction, so repeated moves only need a single undo.
    local dir = distance < 0 and "up" or "down"
    local last_move = vim.b.move_last
    if last_move and last_move.changedtick == vim.b.changedtick and last_move.dir == dir then
        pcall(vim.cmd.undojoin)
    end

    -- After this :move, marks within [first_line, last_line] (including
    -- '</'> if they were set there) are shifted to track the moved lines,
    -- and the cursor ends up on the last moved line.
    vim.cmd(("%d,%d move %d"):format(first_line, last_line, after))

    -- Reindent the block: use `==` on the first line as a heuristic for how
    -- far to shift, then apply the same shift to the rest of the block. This
    -- assumes the first line's indent is <= the rest of the block's indent.
    first_line = vim.fn.line("'[")
    last_line = vim.fn.line("']")

    vim.fn.cursor(first_line, 1)
    local old_indent = vim.fn.indent(".")
    vim.cmd("normal! ==")
    local new_indent = vim.fn.indent(".")

    if first_line < last_line and old_indent ~= new_indent then
        local op = (old_indent < new_indent) and ">" or "<"
        op = op:rep(math.abs(new_indent - old_indent))
        local old_shiftwidth = vim.bo.shiftwidth
        vim.bo.shiftwidth = 1
        vim.cmd(("%d,%d %s"):format(first_line + 1, last_line, op))
        vim.bo.shiftwidth = old_shiftwidth
    end

    vim.fn.cursor(first_line, 1)
    vim.cmd("normal! 0m[")
    vim.fn.cursor(last_line, 1)
    vim.cmd("normal! $m]")

    vim.b.move_last = { changedtick = vim.b.changedtick, dir = dir }
end

--- Moves the current line vertically, keeping the cursor on the same
--- character (relative to the line's indentation) as before the move.
---@param distance integer
local function move_line_vertically(distance)
    local old_col = vim.fn.col(".")
    vim.cmd("normal! ^")
    local old_indent = vim.fn.col(".")

    move_vertically(".", ".", distance)

    vim.cmd("normal! ^")
    local new_indent = vim.fn.col(".")
    vim.fn.cursor(vim.fn.line("."), math.max(1, old_col - old_indent + new_indent))
end

--- Moves the visually selected lines vertically, then restores the
--- selection over the moved lines.
---@param distance integer
local function move_block_vertically(distance)
    -- Leaving Visual mode sets the '< and '> marks to the current
    -- selection; the :move below then keeps them (and thus the selection)
    -- in sync with the moved lines.
    vim.cmd("normal! \x1b")
    move_vertically("'<", "'>", distance)
    vim.cmd("normal! gv")
end

vim.keymap.set("n", "<A-j>", function()
    move_line_vertically(vim.v.count1)
end, { desc = "Move line down" })

vim.keymap.set("n", "<A-k>", function()
    move_line_vertically(-vim.v.count1)
end, { desc = "Move line up" })

vim.keymap.set("x", "<A-j>", function()
    move_block_vertically(vim.v.count1)
end, { desc = "Move selection down" })

vim.keymap.set("x", "<A-k>", function()
    move_block_vertically(-vim.v.count1)
end, { desc = "Move selection up" })
