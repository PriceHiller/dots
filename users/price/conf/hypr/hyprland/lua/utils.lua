local M = {}

---@param o table
---@param indent string?
---@return string
function M.dump(o, indent)
    indent = indent or "  "
    if type(o) == "table" then
        local s = "{\n"
        for k, v in pairs(o) do
            local key = type(k) == "string" and string.format("%q", k) or tostring(k)
            s = s .. indent .. "  [" .. key .. "] = " .. M.dump(v, indent .. "  ") .. ",\n"
        end
        return s .. indent .. "}"
    elseif type(o) == "string" then
        return string.format("%q", o)
    else
        return tostring(o)
    end
end

return M
