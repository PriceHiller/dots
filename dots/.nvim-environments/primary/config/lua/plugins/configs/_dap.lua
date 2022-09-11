local dap = require("dap")
local async = require("plenary.async")

--- Gets a path for a given program in the environment
---@param program @The string of a program in the PATH
---@return @The full path to the program if found, or nil if not
local function get_program_path(program)
    local program_path = vim.fn.stdpath("data") .. "/mason/packages/" .. program .. "/" .. program
    return program_path
end

local lldb_path = get_program_path("codelldb")
-- Adapaters
dap.adapters.lldb = {
    type = "executable",
    command = lldb_path,
    name = "lldb",
}

dap.adapters.coreclr = {
    type = "executable",
    command = get_program_path("netcoredbg"),
    args = { "--interpreter=vscode" },
}

-- configurations
dap.configurations.cpp = {
    {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        targetArchitecture = "arm64",
        args = {},

        -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
        --
        --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --
        -- Otherwise you might get the following error:
        --
        --    Error on launch: Failed to attach to the target process
        --
        -- But you should be aware of the implications:
        -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        runInTerminal = false,
    },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
    },
}
