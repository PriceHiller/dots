<<<<<<< HEAD
local loaded, neoclip = pcall(require, "neoclip")
if not loaded then
    return
end
neoclip.setup({
||||||| b136610 (feat(nvim): use loaded, plugin format)
local neoclip = pcall(require, "neoclip")
if not neoclip then
    return
end
neoclip.setup({
=======
require('neoclip').setup({
>>>>>>> parent of b136610 (feat(nvim): use loaded, plugin format)
    enable_persistent_history = true,
})
