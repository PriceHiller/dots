local List = {}

---@generic T, V
---@param dest V[]
---@param src T[]
---@return (T | V)[]
---@nodiscard
function List.append(dest, src)
    return table.move(src, 1, #src, #dest + 1, dest)
end

---@generic T, V
---@param dest V[]
---@param src T[]
---@return (T | V)[]
---@nodiscard
function List.prepend(dest, src)
    return List.append(src, dest)
end

return List
