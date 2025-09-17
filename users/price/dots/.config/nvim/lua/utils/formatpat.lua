---@alias fmtpat.Pattern string[]

---@class fmtpat.FormatPat
local FormatPat = {
    ---@type fmtpat.Pattern
    start_pat = { [[^\s*]] },
    ---@type fmtpat.Pattern
    end_pat = { [[\s*]] },
    ---@type fmtpat.Pattern
    pat = {
        [[-]],
        [[\d\.]],
        [[+]],
    },
}

---@param cfg fmtpat.FormatPat?
---@return fmtpat.FormatPat
function FormatPat.new(cfg)
    cfg = cfg or {}

    cfg = setmetatable(cfg, {
        __index = FormatPat,
    })
    return cfg
end

---@private
---@param pat fmtpat.Pattern
---@return string
function FormatPat.pat_to_string(pat)
    return ([[\(%s\)]]):format(table.concat(pat, [[\|]]))
end

---@return string
function FormatPat:listpat()
    local pats = {
        self.pat_to_string(self.start_pat),
        self.pat_to_string(self.pat),
        self.pat_to_string(self.end_pat),
    }
    return table.concat(pats)
end

return FormatPat
