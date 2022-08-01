local os = require("os")
local M = {}

M.Table = {}

--- Dump a table into a json-ish string format,
--- shamelessly taken from https://stackoverflow.com/a/27028488
---@param o table
function M.Table.dump(o)
    if type(o) == "table" then
        local s = "{\n"
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "  [" .. k .. "] = " .. M.Table.dump(v) .. ",\n"
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

--- Allows the combining of multiple tables, where the last table given has the highest
--- priority (it overrides the keys of other tables)
---@vararg table
---@return table
function M.Table.merge(...)
    local ret = {}
    for _, tbl in ipairs({ ... }) do
        for k, v in pairs(tbl) do
            ret[k] = v
        end
    end
    return ret
end

--- Return a table with `name` representing the OS name and `arch` representing
--- the architecture.
---
--- For Windows, the OS identification is based on environment variables
--- On unix, a call to uname is used.
---
--- OS possible values: Windows, Linux, Mac, BSD, Solaris
--- Arch possible values: x86, x86864, powerpc, arm, mips
---
--- On Windows, detection based on environment variable is limited
--- to what Windows is willing to tell through environement variables. In particular
--- 64bits is not always indicated so do not rely hardly on this value.
---
--- NOTE: Adapted from (and credit to): https://github.com/bluebird75/lua_get_os_name
function M.get_os_arch()
    local raw_os_name, raw_arch_name = "", ""

    -- LuaJIT shortcut
    if package.config:sub(1, 1) == "\\" then
        -- Windows
        -- NOTE: See https://docs.microsoft.com/en-us/windows/win32/winprog64/wow64-implementation-details
        local env_OS = os.getenv("OS")
        local env_ARCH = os.getenv("PROCESSOR_ARCHITECTURE")
        if env_OS then
            raw_os_name = env_OS
        end
        if env_ARCH then
            raw_arch_name = env_ARCH
        end

        if not env_OS then
            -- Windows variables were not forthcoming, time to check variables
            -- that are less system dependent, but still pretty much a Windows
            -- only thing. Everything under this `else` statement is a fallback,
            -- a prayer that we can extract some information instead of none.

            -- Gather Variables

            -- Most consistent variable to dependend upon for user detection
            local env_USERPROFILE = os.getenv("USERPROFILE")

            -- If these two exist then the user has logged in once and explorer
            -- has generated these variables
            local env_HOME = os.getenv("HOMEPATH")
            local env_HOME_DRIVE = os.getenv("HOMEDRIVE")

            if env_USERPROFILE then
                raw_os_name = "windows"
            elseif env_HOME and env_HOME_DRIVE then
                raw_os_name = "windows"
            end
        end
    else
        -- other platform, assume uname support and popen support
        raw_os_name = io.popen("uname -s", "r"):read("*l")
        raw_arch_name = io.popen("uname -m", "r"):read("*l")

        -- TODO: Increase the backup checks done here in the instance uname is
        -- TODO: is not found/giving poor results
    end

    raw_os_name = raw_os_name:lower()
    raw_arch_name = raw_arch_name:lower()

    local os_patterns = {
        ["windows"] = "Windows",
        ["linux"] = "Linux",
        ["osx"] = "Mac",
        ["mac"] = "Mac",
        ["darwin"] = "Mac",
        ["^mingw"] = "Windows",
        ["^cygwin"] = "Windows",
        ["bsd$"] = "BSD",
        ["sunos"] = "Solaris",
    }

    local arch_patterns = {
        ["^x86$"] = "x86",
        ["i[%d]86"] = "x86",
        ["amd64"] = "x86_64",
        ["x86_64"] = "x86_64",
        ["x64"] = "x86_64",
        ["power macintosh"] = "powerpc",
        ["^arm"] = "arm",
        ["^mips"] = "mips",
        ["i86pc"] = "x86",
    }

    local os_name, arch_name = "", ""

    for pattern, name in pairs(os_patterns) do
        if raw_os_name:match(pattern) then
            os_name = name
            break
        end
    end
    for pattern, name in pairs(arch_patterns) do
        if raw_arch_name:match(pattern) then
            arch_name = name
            break
        end
    end

    local os_table = {
        name = os_name,
        arch = arch_name,
    }
    return os_table
end

return M
