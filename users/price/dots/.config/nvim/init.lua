-- This might look kind of cursed, but lua 5.1 (which Neovim uses) doesn't actually pre-seed the
-- pseudo-random generator by default -- thus, we need to seed it with something that is
-- non-deterministic
--
-- Without this, each call of `math.random` actually results in the exact same outputs across a
-- session of Neovim
--
-- See https://www.lua.org/manual/5.1/manual.html#pdf-math.random
math.randomseed(vim.uv.hrtime())

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
