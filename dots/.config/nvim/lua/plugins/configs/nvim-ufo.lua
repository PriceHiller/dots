vim.api.nvim_create_autocmd("BufReadPre", {
    callback = function()
        vim.b.ufo_foldlevel = 0
    end
})

---@param num integer Set the fold level to this number
local set_buf_foldlevel = function(num)
    vim.b.ufo_foldlevel = num
    require("ufo").closeFoldsWith(num)
end

---@param num integer The amount to change the UFO fold level by
local change_buf_foldlevel_by = function(num)
    local foldlevel = vim.b.ufo_foldlevel or 0
    -- Ensure the foldlevel can't be set negatively
    if foldlevel + num >= 0 then
        foldlevel = foldlevel + num
    else
        foldlevel = 0
    end
    set_buf_foldlevel(foldlevel)
end

return {
    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        event = { "BufRead", "BufNewFile" },
        keys = {
            {
                "zR",
                function()
                    require("ufo").openAllFolds()
                end,
                desc = "UFO: Open All Folds",
            },
            {
                "zM",
                function()
                    require("ufo").closeAllFolds()
                end,
                desc = "UFO: Close All Folds",
            },
            {
                "zm",
                function()
                    local count = vim.v.count
                    if count == 0 then
                        count = 1
                    end
                    change_buf_foldlevel_by(-(count))
                end,
                desc = "UFO: Fold Less",
            },
            {
                "zr",
                function()
                    local count = vim.v.count
                    if count == 0 then
                        count = 1
                    end
                    change_buf_foldlevel_by(count)
                end,
                desc = "UFO: Fold More",
            },
            {
                "zS",
                function()
                    if vim.v.count == 0 then
                        vim.notify("No foldlevel given to set!", vim.log.levels.WARN)
                    else
                        set_buf_foldlevel(vim.v.count)
                    end
                end,
                desc = "UFO: Set Foldlevel",
            },
        },
        opts = function()
            vim.opt.foldlevel = 99

            -- Show numbers for fold text
            local handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" {...} 󰁂 %d "):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, "@conditional" })
                return newVirtText
            end

            local ft_options = { norg = "", octo = "", NeogitStatus = "" }
            return {
                provider_selector = function(_, filetype, _)
                    return ft_options[filetype] or { "treesitter", "indent" }
                end,
                fold_virt_text_handler = handler,
            }
        end,
    },
}
