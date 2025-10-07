---@param perms string The permissions to set the file to, e.g. 0744
---@param fpath string The file path to set the permissions on
---@return vim.SystemCompleted
local function chmod(perms, fpath)
    return vim.system({ "chmod", perms, fpath }):wait()
end

---@param bufnr integer
---@return string? abs_fpath The absolute path to the file if found
local function get_bufnr_fpath(bufnr)
    local bufopts = vim.bo[bufnr]
    if (not bufopts) or bufopts.buftype ~= "" then
        return nil
    end

    local bufpath = vim.api.nvim_buf_get_name(bufnr)
    bufpath = vim.fs.abspath(bufpath)
    bufpath = vim.fs.normalize(bufpath)
    if not vim.uv.fs_stat(bufpath) then
        return nil
    end

    return bufpath
end

local augroup = vim.api.nvim_create_augroup("autochmod", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    desc = "Make shell scripts executable",
    pattern = {
        "*.sh",
        "*.bash",
        "*.zsh",
    },
    callback = function(args)
        local bufpath = get_bufnr_fpath(args.buf)
        if not bufpath then
            return
        end
        chmod("u+x", bufpath)
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    desc = "Make files executable if they contain a shebang",
    pattern = "*",
    callback = function(args)
        local first_line = vim.api.nvim_buf_get_lines(args.buf, 0, 1, true)[1]
        if not first_line:match("^#!.*$") then
            return
        end

        local bufpath = get_bufnr_fpath(args.buf)
        if not bufpath then
            return
        end
        chmod("u+x", bufpath)
    end,
})
