local require_proxy = require("utils.funcs").require_proxy
local schemastore = require_proxy("schemastore")

local vscode_snippets_name = "VSCode Code Snippets"

---@param name string
local get_snippet_or_err = function(name)
    local snippet = schemastore.json.get(name)
    if not snippet then
        error(("Unable to get snippet: '%s'"):format(name))
    end
    return snippet
end

return {
    ---@type lspconfig.settings.jsonls
    settings = {
        json = {
            schemas = schemastore.json.schemas({
                replace = {
                    [vscode_snippets_name] = (function()
                        local vscode_snippets_ext = get_snippet_or_err(vscode_snippets_name)
                        local filematch = (type(vscode_snippets_ext.fileMatch) == "table")
                                and vscode_snippets_ext.fileMatch
                            or { vscode_snippets_ext.fileMatch }

                        ---@cast filematch string[]

                        table.insert(filematch, "**/nvim/snippets/*.json")
                        vscode_snippets_ext.fileMatch = filematch
                        return vscode_snippets_ext
                    end)(),
                },
            }),
            validate = { enable = true },
        },
    },
}
