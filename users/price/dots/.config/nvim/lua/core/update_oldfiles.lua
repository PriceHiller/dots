local M = {}

--- Update the old files with a new file
---@param file string An absolute filepath
M.update_oldfiles = function(file)
    if not vim.v.oldfiles then
        return
    end
    if not vim.fn.filereadable(file) or not vim.uv.fs_stat(file) then
        return
    end
    local oldfiles = vim.v.oldfiles
    ---@type integer | nil
    for idx, oldfile in ipairs(oldfiles) do
        if oldfile == file then
            table.remove(oldfiles, idx)
            break
        end
    end
    table.insert(oldfiles, 1, file)
    vim.v.oldfiles = oldfiles
end

local did_setup = false

M.setup = function()
    if did_setup then
        return
    end
    did_setup = true

    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufReadPre", "BufDelete" }, {
        callback = function(args)
            local file = args.file
            M.update_oldfiles(file)
        end,
    })
end

return M
