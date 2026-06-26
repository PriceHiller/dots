local require_proxy = require("utils.funcs").require_proxy

return {
    handlers = {
        ["textDocument/definition"] = require_proxy("csharpls_extended").handler,
    },
}
