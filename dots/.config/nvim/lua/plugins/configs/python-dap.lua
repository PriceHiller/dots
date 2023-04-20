local dap_python = require("dap-python")
dap_python.setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python3")
dap_python.test_runner = "pytest"
