local utils = require("utils")
return {
    init_options = {
        ["language_server_php_cs_fixer.enabled"] = true,
        ["language_server_php_cs_fixer.bin"] = utils.funcs.get_program_path("php-cs-fixer"),
        ["language_server_psalm.enabled"] = true,
        ["language_server_psalm.bin"] = utils.funcs.get_program_path("psalm"),
    },
}
