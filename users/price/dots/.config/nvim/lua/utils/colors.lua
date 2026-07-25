---@class Color
---@field r integer Red (0-255)
---@field g integer Green (0-255)
---@field b integer Blue (0-255)
local Color = {}
Color.__index = Color

--- Constructs an `Color` from either a 24-bit integer (as returned by
--- `nvim_get_hl` for a given value, e.g. `fg`), a `"#RRGGBB"` hex string, or
--- an existing `Color` (returned as-is)
---@param color integer | string | Color
---@return Color
function Color.from(color)
    if getmetatable(color) == Color then
        ---@cast color Color
        return color
    elseif type(color) == "number" then
        return setmetatable({
            r = math.floor(color / 65536) % 256, -- (color >> 16) & 0xFF
            g = math.floor(color / 256) % 256, -- (color >> 8)  & 0xFF
            b = color % 256, -- color & 0xFF
        }, Color)
    elseif type(color) == "string" then
        local hex = "[abcdef0-9][abcdef0-9]"
        local pat = "^#(" .. hex .. ")(" .. hex .. ")(" .. hex .. ")$"
        local hex_rgb_str = string.lower(color)

        assert(string.find(hex_rgb_str, pat) ~= nil, "Color.from: invalid hex_str: " .. tostring(color))

        local r, g, b = string.match(hex_rgb_str, pat)
        return setmetatable({ r = tonumber(r, 16), g = tonumber(g, 16), b = tonumber(b, 16) }, Color)
    else
        error("Color.from: unsupported color type: " .. type(color))
    end
end

--- Returns this color as a `"#RRGGBB"` hex string
---@return string
function Color:toHex()
    return string.format("#%02X%02X%02X", self.r, self.g, self.b)
end

--- Returns a new `Color` instance with the same r/g/b values as this one
---@return Color
function Color:clone()
    return setmetatable({ r = self.r, g = self.g, b = self.b }, Color)
end

--- Blends this color with `other` by `alpha` (0 = fully `other`, 1 = fully `self`)
---@param other integer | string | Color
---@param alpha number alpha is clamped to the [0, 1] range
---@return Color
function Color:blend(other, alpha)
    local bg = Color.from(other)
    alpha = math.min(math.max((1 - math.abs(alpha)), 0), 1)

    local blendChannel = function(channel)
        local ret = (alpha * self[channel] + ((1 - alpha) * bg[channel]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return setmetatable({
        r = blendChannel("r"),
        g = blendChannel("g"),
        b = blendChannel("b"),
    }, Color)
end

--- Darkens this color by blending it towards black
---@param amount number
---@return Color
function Color:darken(amount)
    return self:blend("#000000", amount)
end

--- Lightens this color by blending it towards default white
---@param amount number
---@return Color
function Color:lighten(amount)
    return self:blend("#ffffff", amount)
end

return Color
