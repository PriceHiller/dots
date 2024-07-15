return {
    {
        "rcarriga/nvim-dap-ui",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("dapui").setup()
        end,
        keys = {
            {
                "<leader>dt",
                function()
                    require("dapui").toggle({ reset = true })
                end,
                desc = "DAP: Toggle UI",
            },
        },
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        event = { "BufReadPre", "BufNewFile" },
        config = true,
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        config = function()
            local dap_python = require("dap-python")
            dap_python.test_runner = "pytest"
            dap_python.setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python3")
        end,
    },
    {
        "mfussenegger/nvim-dap",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "<leader>d", desc = "> DAP" },
            {
                "<leader>dc",
                "<cmd>DapContinue<CR>",
                desc = "DAP: Continue",
            },
            {
                "<leader>de",
                "<cmd>DapTerminate<CR>",
                desc = "DAP: Terminate",
            },
            {
                "<leader>db",
                "<cmd>DapToggleBreakpoint<CR>",
                desc = "DAP: Toggle Breakpoint",
            },
            {
                "<leader>dr",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint Condition: "))
                end,
                desc = "DAP: Set Conditional Breakpoint",
            },
            {
                "<leader>dp",
                function()
                    require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
                end,
                desc = "DAP: Set Log Breakpoint",
            },
            {
                "<F5>",
                "<cmd>DapStepOver<CR>",
                desc = "DAP: Step Over",
            },
            {
                "<F6>",
                "<cmd>DapStepInto<CR>",
                desc = "DAP: Step Into",
            },
            {
                "<F7>",
                "<cmd>DapStepOut<CR>",
                desc = "DAP: Step Out",
            },
            {
                "<F8>",
                function()
                    require("dap").step_back()
                end,
                desc = "DAP: Step Back",
            },
            {
                "<leader>dR",
                function()
                    require("dap").run_to_cursor()
                end,
                desc = "DAP: Run to Cursor",
            },
            {
                "<leader>do",
                function()
                    require("dap").repl.open()
                end,
                desc = "DAP: Open Repl",
            },
            {
                "<leader>dl",
                function()
                    require("dap").run_last()
                end,
                desc = "DAP: Run Last",
            },
        },
        init = function()
            vim.fn.sign_define(
                "DapBreakpoint",
                { text = "● ", texthl = "DiagnosticSignError", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapBreakpointCondition",
                { text = "● ", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" }
            )
            vim.fn.sign_define("DapLogPoint", { text = "● ", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "→ ", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
            vim.fn.sign_define(
                "DapBreakpointReject",
                { text = "●", texthl = "DiagnosticSignHint", linehl = "", numhl = "" }
            )
            return {}
        end,
        config = function()
            require("dap.ext.vscode").load_launchjs()

            local dap = require("dap")

            --- Gets a path for a given program in the environment
            ---@param program string String of a program in the Mason packages
            ---@return string Full path to the program if found, or nil if not
            local function get_program_path(program)
                local program_path = vim.fn.stdpath("data") .. "/mason/packages/" .. program .. "/" .. program
                return program_path
            end

            local lldb_path = get_program_path("codelldb")
            -- Adapaters
            dap.adapters.lldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = lldb_path,
                    args = { "--port", "${port}" },
                },
                name = "lldb",
            }

            dap.adapters.coreclr = {
                type = "executable",
                command = get_program_path("netcoredbg"),
                args = { "--interpreter=vscode" },
            }

            dap.adapters.bashdb = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
                name = "bashdb",
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
            dap.configurations.asm = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp

            vim.g.dotnet_build_project = function()
                local default_path = vim.fn.getcwd() .. "/"
                if vim.g["dotnet_last_proj_path"] ~= nil then
                    default_path = vim.g["dotnet_last_proj_path"]
                end
                local path = vim.fn.input("Path to your *proj file", default_path, "file")
                vim.g["dotnet_last_proj_path"] = path
                local cmd = "dotnet build -c Debug " .. path .. " > /dev/null"
                print("")
                print("Cmd to execute: " .. cmd)
                local f = os.execute(cmd)
                if f == 0 then
                    print("\nBuild: ✔️ ")
                else
                    print("\nBuild: ❌ (code: " .. f .. ")")
                end
            end

            vim.g.dotnet_get_dll_path = function()
                local request = function()
                    return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
                end

                if vim.g["dotnet_last_dll_path"] == nil then
                    vim.g["dotnet_last_dll_path"] = request()
                else
                    if
                        vim.fn.confirm(
                            "Do you want to change the path to dll?\n" .. vim.g["dotnet_last_dll_path"],
                            "&yes\n&no",
                            2
                        ) == 1
                    then
                        vim.g["dotnet_last_dll_path"] = request()
                    end
                end

                return vim.g["dotnet_last_dll_path"]
            end

            local config = {
                {
                    type = "coreclr",
                    name = "launch - netcoredbg",
                    request = "launch",
                    program = function()
                        if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                            vim.g.dotnet_build_project()
                        end
                        return vim.g.dotnet_get_dll_path()
                    end,
                },
            }

            dap.configurations.cs = config
            dap.configurations.fsharp = config

            dap.configurations.sh = {
                {
                    type = "bashdb",
                    request = "launch",
                    name = "Launch file",
                    showDebugOutput = true,
                    pathBashdb = vim.fn.stdpath("data")
                        .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
                    pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
                    trace = true,
                    file = "${file}",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    pathCat = "cat",
                    pathBash = "/bin/bash",
                    pathMkfifo = "mkfifo",
                    pathPkill = "pkill",
                    args = {},
                    env = {},
                    terminalKind = "integrated",
                },
            }
        end,
    },
}
