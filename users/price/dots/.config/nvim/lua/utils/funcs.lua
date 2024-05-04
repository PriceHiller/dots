local U = {}

U.rgbToHex = function(rgb)
    return string.format("#%06x", rgb)
end

U.hexToRgb = function(hex_str)
    local hex = "[abcdef0-9][abcdef0-9]"
    local pat = "^#(" .. hex .. ")(" .. hex .. ")(" .. hex .. ")$"
    hex_str = string.lower(hex_str)

    assert(string.find(hex_str, pat) ~= nil, "hex_to_rgb: invalid hex_str: " .. tostring(hex_str))

    local r, g, b = string.match(hex_str, pat)
    return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }
end

U.blend = function(fg, bg, alpha)
    bg = U.hexToRgb(bg)
    fg = U.hexToRgb(fg)

    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format("#%02X%02X%02X", blendChannel(1), blendChannel(2), blendChannel(3))
end

U.darken = function(hex, amount, bg)
    return U.blend(hex, bg or "#000000", math.abs(amount))
end

U.lighten = function(hex, amount, fg)
    return U.blend(hex, fg or "#ffffff", math.abs(amount))
end

U.get_color = function(group, attr)
    local fn = vim.fn
    return fn.synIDattr(fn.synIDtrans(fn.hlID(group)), attr)
end

-- https://stackoverflow.com/a/22548737
---Title cases a given string
---@param str string
U.title_case = function(str)
    local function inner(first, rest)
        return first:upper() .. rest:lower()
    end

    return string.gsub(str, "(%a)([%w_']*)", inner)
end

---@alias Highlight.Keys
---| '"bold"'
---| '"standout"'
---| '"strikethrough"'
---| '"underline"'
---| '"undercurl"'
---| '"underdouble"'
---| '"underdotted"'
---| '"underdashed"'
---| '"italic"'
---| '"reverse"'
---| '"altfont"'
---| '"nocombine"'
---| '"default"'
---| '"cterm"'
---| '"foreground"'
---| '"fg"'
---| '"background"'
---| '"bg"'
---| '"ctermfg"'
---| '"ctermbg"'
---| '"special"'
---| '"sp"'
---| '"link"'
---| '"global_link"'
---| '"fallback"'
---| '"blend"'
---| '"fg_indexed"'
---| '"bg_indexed"'
---| '"force"'
---| '"url"'

---Get the effective given highlight, optionally overriding some of its fields
---@param name string Highlight name
---@param opts? vim.api.keyset.highlight | table<Highlight.Keys, fun(): string | integer>
---@return fun(): vim.api.keyset.highlight
U.get_hl = function(name, opts)
    opts = vim.iter(opts or {}):fold({}, function(t, k, v)
        if type(v) == "function" then
            v = v()
        end
        t[k] = v
        return t
    end)
    ---@return vim.api.keyset.highlight
    return function()
        ---@diagnostic disable-next-line: return-type-mismatch
        return vim.tbl_deep_extend("force", vim.api.nvim_get_hl(0, { name = name, link = false }), opts or {})
    end
end

---Get only the specified items from the highlight
---@param name string Highlight name
---@param fields Highlight.Keys[]
---@return fun(): vim.api.keyset.highlight
U.select_hl = function(name, fields)
    ---@return vim.api.keyset.highlight
    return function()
        return vim.iter(U.get_hl(name)())
            :filter(function(k, _)
                return vim.list_contains(fields, k)
            end)
            :fold({}, function(t, k, v)
                t[k] = v
                return t
            end)
    end
end

---Parses a variable amount of strings or table of strings into a single string by concetanting them by spaces
---@vararg string Takes in a variable amount of strings and concatenates them by spaces
---@return string joined_args The built arguments as a single string
U.flatten_args = function(...)
    return vim.iter({ ... }):flatten(math.huge):join(" ")
end

---Synchronously write or overwrite a file with data. All data are joined by newlines and any data
---that are tables are first concatenated by spaces.
---@param path string A file path on the system
---@param mode string A octal mode, like 0700
---@vararg string|string[] A single chunk of data or list of strings to write, if a list then the strings are concatenated by spaces
---@return string path The path written to
U.write_file = function(path, mode, ...)
    local data = vim.iter({ ... }):map(U.flatten_args):join("\n")
    local fd = vim.uv.fs_open(path, "w", tonumber(mode, 8))
    if fd then
        vim.uv.fs_write(fd, data)
        vim.uv.fs_close(fd)
    else
        error("Failed to acquire a file descriptor to write to!")
    end
    return path
end

return U
