local loaded = pcall(require, "plenary.async")

if not loaded then
    return
end

-- Telescope mappings
vim.keymap.set("n", "<Leader>tw", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<Leader>tgs", ":Telescope git_status<CR>")
vim.keymap.set("n", "<Leader>tgc", ":Telescope git_commits<CR>")
vim.keymap.set("n", "<Leader>tgb", ":Telescope git_branches<CR>")
vim.keymap.set("n", "<Leader>tf", ":Telescope find_files<CR>")
vim.keymap.set("n", "<Leader>td", ":Telescope find_directories<CR>")
vim.keymap.set("n", "<Leader>tb", ":Telescope buffers<CR>")
vim.keymap.set("n", "<Leader>th", ":Telescope help_tags<CR>")
vim.keymap.set("n", "<Leader>to", ":Telescope oldfiles<CR>")
vim.keymap.set("n", "<leader>tc", ":Telescope neoclip default<CR>")
vim.keymap.set("n", "<leader>tr", ":Telescope registers<CR>")
vim.keymap.set("n", "<leader>tt", ":Telescope file_browser<CR>")
vim.keymap.set("n", "<leader>ts", ":Telescope spell_suggest<CR>")
vim.keymap.set("n", "<leader>tl", ":Telescope resume<CR>")
vim.keymap.set("n", "<leader>tT", ":TodoTelescope<CR>")

-- Lsp Mappings
vim.keymap.set("n", "<leader>lD", ":lua vim.lsp.buf.declaration()<CR>")
vim.keymap.set("n", "<leader>ld", ":lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "<leader>k", ":lua vim.lsp.buf.hover()<CR>")
vim.keymap.set("n", "<leader>K", ":lua vim.lsp.buf.signature_help()<CR>")
vim.keymap.set("n", "<leader>li", ":lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "<leader>la", ":lua vim.lsp.buf.add_workspace_folder()<CR>")
vim.keymap.set("n", "<leader>lx", ":lua vim.lsp.buf.remove_workspace_folder()<CR>")
vim.keymap.set("n", "<leader>ll", ":lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
vim.keymap.set("n", "<leader>ln", ":IncRename ")
vim.keymap.set("n", "<leader>lc", ":CodeActionMenu<CR>")
vim.keymap.set("n", "<leader>lr", ":lua vim.lsp.buf.references()<CR>")
vim.keymap.set("n", "<leader>lR", function()
    vim.diagnostic.reset()
    vim.cmd(":LspRestart<CR>")
end)
vim.keymap.set("n", "<leader>ls", ":lua vim.diagnostic.open_float(nil, {focus=false, scope='cursor'})<CR>")
vim.keymap.set("n", "<leader>lf", ":lua vim.lsp.buf.format({ async = true })<CR>")
vim.keymap.set("n", "[l", ":lua vim.diagnostic.goto_prev()<CR>")
vim.keymap.set("n", "]l", ":lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "<leader>lq", ":Telescope diagnostics bufnr=0<CR>")
vim.keymap.set("n", "<leader>lt", function()
    local virtual_lines_enabled = not vim.diagnostic.config().virtual_lines
    vim.diagnostic.config({ virtual_lines = virtual_lines_enabled, virtual_text = not virtual_lines_enabled })
end, {
    desc = "Toggle LSP Diag Style",
})

-- Trouble mappings
vim.keymap.set("n", "<leader>lT", ":TroubleToggle<CR>")

-- Formatter
vim.keymap.set("n", "<leader>nf", ":Neoformat<CR>")

-- DAP Mappings
vim.keymap.set("n", "<leader>dR", ':lua require("dap").continue()<CR>')
vim.keymap.set("n", "<leader>de", ':lua require("dap").terminate()<CR>')
vim.keymap.set("n", "<leader>db", ':lua require("dap").toggle_breakpoint()<CR>')
vim.keymap.set("n", "<leader>dr", ":lua require(\"dap\").set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set(
    "n",
    "<leader>dp",
    ":lua require(\"dap\").set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>"
)
vim.keymap.set("n", "<F5>", ':lua require("dap").step_over()<CR>')
vim.keymap.set("n", "<F6>", ':lua require("dap").step_into()<CR>')
vim.keymap.set("n", "<F7>", ':lua require("dap").step_out()<CR>')
vim.keymap.set("n", "<leader>dB", ':lua require("dap").step_back()<CR>')
vim.keymap.set("n", "<leader>dc", ':lua require("dap").run_to_cursor()<CR>')
vim.keymap.set("n", "<leader>do", ':lua require("dap").repl.open()<CR>')
vim.keymap.set("n", "<leader>dt", ':lua require("dapui").toggle()<CR>')
vim.keymap.set("n", "<leader>dl", ':lua require("dap").run_last()<CR>')

-- Comments
vim.keymap.set("n", "<leader>/", ":CommentToggle<CR>")
vim.keymap.set("v", "<leader>/", ":'<,'>CommentToggle<CR>")

-- Bufferline mappings
vim.keymap.set("n", "<A-a>", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<A-s>", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<A-x>", ":lua require('utils.funcs').close_buffer()<CR>")

-- Vim Notify Mappings
vim.keymap.set("n", "<leader>nv", ":lua require('telescope').extensions.notify.notify()<CR>")
vim.keymap.set("n", "<leader>nd", ":lua require('notify').dismiss()<CR>")

-- Whichkey Mappings
vim.keymap.set("n", "<leader>ww", ":WhichKey<CR>")
vim.keymap.set("n", "<leader>wk", ":Telescope keymaps<CR>")
vim.keymap.set("n", "<leader>wc", ":Telescope commands<CR>")

-- Neogen Mappings
vim.keymap.set("n", "<leader>ng", ":Neogen<CR>")

-- Nvim Tree Mappings
vim.keymap.set("n", "<leader>nt", ":Neotree show toggle focus<cr>")

-- Plenary Mappings
vim.keymap.set("n", "<leader>pt", "<Plug>PlenaryTestFile", {})

-- Zenmode Mappings
vim.keymap.set("n", "<leader>zm", ":ZenMode<CR>")

-- Neogit Mappings
vim.keymap.set("n", "<leader>gg", ":Neogit<CR>")

-- Gitsigns Mappings
vim.keymap.set("n", "]g", "<cmd>Gitsigns next_hunk<CR>")
vim.keymap.set("n", "[g", "<cmd>Gitsigns prev_hunk<CR>")
vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>")
vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>")
vim.keymap.set("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>")

-- Packer Mappings
local packer = require("packer")
local packer_sync = function()
    vim.notify("Syncing packer.", "info", {
        title = "Packer",
    })
    local snap_shot_time = tostring(os.date("!%Y-%m-%dT%TZ"))
    packer.snapshot(snap_shot_time)
    packer.sync()
end

local packer_compile = function()
    vim.notify("Compiling packer.", "info", {
        title = "Packer",
    })
    packer.compile()
end

vim.keymap.set("n", "<leader>ps", packer_sync, {
    desc = "PackerSync",
})

vim.keymap.set("n", "<leader>pc", packer_compile, {
    desc = "PackerCompile",
})

-- Mundo mappings
vim.keymap.set("n", "<leader>ut", ":MundoToggle<CR>")

-- Hop Mappings
local hop = require("hop")

vim.keymap.set("", "f", function()
    hop.hint_char1({
        current_line_only = false,
    })
end)

-- Hop Bindings
vim.keymap.set("", ";l", "<cmd>HopLineStart<CR>")
vim.keymap.set("", ";s", "<cmd>HopPattern<CR>")
vim.keymap.set("", ";;", "<cmd>HopWord<CR>")
vim.keymap.set("", ";a", "<cmd>HopAnywhere<CR>")
vim.keymap.set("", ";v", "<cmd>HopVertical<CR>")
