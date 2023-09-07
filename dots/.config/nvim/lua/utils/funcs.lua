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


return U
