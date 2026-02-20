-- See https://wkillerud.github.io/some-sass/language-server/settings.html
local default_sass_settngs = {
    completion = {
        suggestFromUseOnly = true,
    },
}
return {
    settings = {
        scss = default_sass_settngs,
        sass = default_sass_settngs,
    },
}
