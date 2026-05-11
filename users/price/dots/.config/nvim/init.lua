vim.loader.enable()

-- This pcall dance is done to ensure Neovim isn't blocked on load for certain applications. For
--
-- instance, an immediate error causes Neovide to never show its main window, by delaying the error
-- message for a short interval, we ensure it can appear.
local success, err_msg = pcall(require, "main")
if not success then
    vim.defer_fn(function()
        vim.notify(err_msg, vim.log.levels.ERROR)
    end, 10)
end
