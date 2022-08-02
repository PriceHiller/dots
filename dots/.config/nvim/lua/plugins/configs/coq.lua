-- Alias for vim.g
local g = vim.g

-- Run COQ on open
g.coq_settings = {
    auto_start = 'shut-up',
    limits = {
        completion_manual_timeout = 2000,
    },
}
