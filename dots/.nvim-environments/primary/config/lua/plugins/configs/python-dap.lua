local loaded, dap_python = pcall(require, "dap-python")
if not loaded then
    return
end
dap_python.setup("~/.venvs/debugpy/bin/python")
dap_python.test_runner = "pytest"
