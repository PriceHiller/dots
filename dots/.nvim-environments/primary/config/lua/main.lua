-- INFO: Primary loading, where most things are loaded in
--
-- INFO: All modules/dirs that are going to be loaded
-- INFO: SHOULD have a init.lua file associated with them.
-- INFO: init.lua is responsible for loading all configuration
-- INFO: related to that directory.
require("core.init")
require("plugins.init")

-- INFO: Post load, for things that need to setup keybindings etc after the fact
--
-- NOTE: All postload modules should be independent of each other, they shouldn't
-- NOTE: rely on each other's load order. That type of logic should be shifted
-- NOTE: into non-postload regions then handled in postload modules.
require("plugins.postload")
require("core.postload")
