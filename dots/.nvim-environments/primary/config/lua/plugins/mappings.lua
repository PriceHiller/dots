local loaded = pcall(require, "plenary.async")

if not loaded then
    return
end

local wk = require("which-key")

-- Telescope mappings
wk.register({
    t = {
        name = "Telescope",
    },
}, { prefix = "<leader>" })
vim.keymap.set("n", "<Leader>tw", ":Telescope live_grep<CR>", { silent = true, desc = "Telescope: Grep for Word" })
vim.keymap.set("n", "<Leader>tgs", ":Telescope git_status<CR>", { silent = true, desc = "Telescope: Git Status" })
vim.keymap.set("n", "<Leader>tgc", ":Telescope git_commits<CR>", { silent = true, desc = "Telescope: Git Commits" })
vim.keymap.set("n", "<Leader>tgb", ":Telescope git_branches<CR>", { silent = true, desc = "Telescope: Git Branches" })
vim.keymap.set("n", "<Leader>tf", ":Telescope find_files<CR>", { silent = true, desc = "Telescope: Find Files" })
vim.keymap.set(
    "n",
    "<Leader>td",
    ":Telescope find_directories<CR>",
    { silent = true, desc = "Telescope: Find Directories" }
)
vim.keymap.set("n", "<Leader>tb", ":Telescope buffers<CR>", { silent = true, desc = "Telescope: Buffers" })
vim.keymap.set("n", "<Leader>th", ":Telescope help_tags<CR>", { silent = true, desc = "Telescope: Help Tags" })
vim.keymap.set("n", "<Leader>to", ":Telescope oldfiles<CR>", { silent = true, desc = "Telescope: Recent Files" })
vim.keymap.set(
    "n",
    "<leader>tn",
    ":Telescope neoclip default<CR>",
    { silent = true, desc = "Telescope: Neoclip Buffer" }
)
vim.keymap.set("n", "<leader>tr", ":Telescope registers<CR>", { silent = true, desc = "Telescope: Registers" })
vim.keymap.set("n", "<leader>tt", ":Telescope file_browser<CR>", { silent = true, desc = "Telescope: File Tree" })
vim.keymap.set("n", "<leader>ts", ":Telescope spell_suggest<CR>", { silent = true, desc = "Telescope: Spell Suggest" })
vim.keymap.set("n", "<leader>tl", ":Telescope resume<CR>", { silent = true, desc = "Telescope: Previous State" })
vim.keymap.set("n", "<leader>tT", ":TodoTelescope<CR>", { silent = true, desc = "Telescope: Todo Items" })
vim.keymap.set("n", "<leader>tk", ":Telescope keymaps<CR>", { silent = true, desc = "Telescope: Keymaps" })
vim.keymap.set("n", "<leader>tc", ":Telescope commands<CR>", { silent = true, desc = "Telescope: Commands" })

-- Lsp Mappings

wk.register({
    l = {
        name = "LSP",
    },
}, { prefix = "<leader>" })
vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, { silent = true, desc = "LSP: Declaration" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { silent = true, desc = "LSP: Definition" })
vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, { silent = true, desc = "LSP: Hover" })
vim.keymap.set("n", "<leader>K", vim.lsp.buf.signature_help, { silent = true, desc = "LSP: Sig Help" })
vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, { silent = true, desc = "LSP: Implementation" })
vim.keymap.set(
    "n",
    "<leader>la",
    vim.lsp.buf.add_workspace_folder,
    { silent = true, desc = "LSP: Add Workspace Folder" }
)
vim.keymap.set(
    "n",
    "<leader>lx",
    vim.lsp.buf.remove_workspace_folder,
    { silent = true, desc = "LSP: Remove Workspace Folder" }
)
vim.keymap.set("n", "<leader>ll", function()
    local output_workspaces = ""
    for _, workspace in ipairs(vim.lsp.buf.list_workspace_folders()) do
        output_workspaces = string.format("%s- %s\n", output_workspaces, vim.inspect(workspace):gsub('%"', ""))
    end
    vim.notify(output_workspaces:gsub("\n[^\n]*$", ""), "info", { title = "LSP: Workspaces" })
end, { silent = true, desc = "LSP: List Workspaces" })
vim.keymap.set("n", "<leader>ln", function() end, { silent = true })
vim.keymap.set("n", "<leader>ln", ":IncRename ", { desc = "LSP: Rename" })
vim.keymap.set("n", "<leader>lc", vim.lsp.buf.code_action, { silent = true, desc = "LSP: Code Action" })
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, { silent = true, desc = "LSP: References" })
vim.keymap.set("n", "<leader>lR", ":LspRestart<CR>", { silent = true, desc = "LSP: Restart" })
vim.keymap.set("n", "<leader>ls", function()
    vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
end, { silent = true, desc = "LSP: Diagnostic Open Float" })
vim.keymap.set("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "LSP: Format" })
vim.keymap.set("n", "[l", vim.diagnostic.goto_prev, { silent = true, desc = "LSP: Diagnostic Previous" })
vim.keymap.set("n", "]l", vim.diagnostic.goto_next, { silent = true, desc = "LSP: Diagnostic Next" })
vim.keymap.set(
    "n",
    "<leader>lq",
    ":Telescope diagnostics bufnr=0<CR>",
    { silent = true, desc = "LSP: Telescope Diagnostics" }
)
vim.keymap.set("n", "<leader>lt", function()
    local virtual_lines_enabled = not vim.diagnostic.config().virtual_lines
    vim.diagnostic.config({ virtual_lines = virtual_lines_enabled, virtual_text = not virtual_lines_enabled })
end, {
    desc = "LSP: Toggle Diagnostic Style",
})

-- Formatter
vim.keymap.set("n", "<leader>nf", ":Neoformat<CR>", { silent = true, desc = "Neoformat" })

-- DAP Mappings
wk.register({
    d = {
        name = "DAP",
    },
}, { prefix = "<leader>" })
local dap = require("dap")
vim.keymap.set("n", "<leader>dc", dap.continue, { silent = true, desc = "DAP: Continue" })
vim.keymap.set("n", "<leader>de", dap.terminate, { silent = true, desc = "DAP: Terminate" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { silent = true, desc = "DAP: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dr", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint Condition: "))
end, { silent = true, desc = "DAP: Set Conditional Breakpoint" })

vim.keymap.set("n", "<leader>dp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { silent = true, desc = "DAP: Set Log Breakpoint" })
vim.keymap.set("n", "<F5>", dap.step_over, { silent = true, desc = "DAP: Step Over" })
vim.keymap.set("n", "<F6>", dap.step_into, { silent = true, desc = "DAP: Step Into" })
vim.keymap.set("n", "<F7>", dap.step_out, { silent = true, desc = "DAP: Step Out" })
vim.keymap.set("n", "<F8>", dap.step_back, { silent = true, desc = "DAP: Step Back" })
vim.keymap.set("n", "<leader>dR", dap.run_to_cursor, { silent = true, desc = "DAP: Run to Cursor" })
vim.keymap.set("n", "<leader>do", dap.repl.open, { silent = true, desc = "DAP: Open Repl" })
vim.keymap.set("n", "<leader>dt", require("dapui").toggle, { silent = true, desc = "DAP: Toggle UI" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { silent = true, desc = "DAP: Run Last" })

-- Comments
vim.keymap.set("n", "<leader>/", ":CommentToggle<CR>", { silent = true, desc = "Toggle Comment" })
vim.keymap.set("v", "<leader>/", ":'<,'>CommentToggle<CR>", { silent = true, desc = "Toggle Selection Comment" })

-- Buffer mappings
vim.keymap.set("n", "<A-a>", ":bprevious<CR>", { silent = true, desc = "Go to Previous Buffer" })
vim.keymap.set("n", "<A-s>", ":bnext<CR>", { silent = true, desc = "Go to Next Buffer" })
vim.keymap.set("n", "<A-x>", function()
    require("bufdelete").bufdelete(0)
end, { silent = true, desc = "Close Buffer" })

-- Vim Notify Mappings
vim.keymap.set("n", "<leader>nv", ":Telescope notify<CR>", { silent = true, desc = "Notifications: Search" })
vim.keymap.set("n", "<leader>nd", require("notify").dismiss, { silent = true, desc = "Notifications: Dismiss" })

-- Whichkey Mappings
vim.keymap.set("n", "<leader>ww", ":WhichKey<CR>", { silent = true, desc = "Show Keybinds" })

-- Neogen Mappings
wk.register({
    n = {
        g = {
            name = "Neogen",
        },
    },
}, { prefix = "<leader>" })
vim.keymap.set("n", "<leader>ngf", ":Neogen func<CR>", { silent = true, desc = "Neogen: Function Annotation" })
vim.keymap.set("n", "<leader>ngc", ":Neogen class<CR>", { silent = true, desc = "Neogen: Class Annotation" })
vim.keymap.set("n", "<leader>ngt", ":Neogen type<CR>", { silent = true, desc = "Neogen: Type Annotation" })
vim.keymap.set("n", "<leader>ngb", ":Neogen file<CR>", { silent = true, desc = "Neogen: File Annotation" })

-- Nvim Tree Mappings
vim.keymap.set("n", "<leader>nt", ":Neotree show toggle focus<cr>", { silent = true, desc = "Neotree: Toggle" })

-- Plenary Mappings
vim.keymap.set("n", "<leader>pt", "<Plug>PlenaryTestFile", { silent = true, desc = "Plenary: Test File" })

-- Neogit Mappings
wk.register({
    g = {
        name = "Git",
    },
}, { prefix = "<leader>" })
vim.keymap.set("n", "<leader>gg", require("neogit").open, { silent = true, desc = "Neogit: Open" })

-- Gitsigns Mappings
vim.keymap.set("n", "]g", "<cmd>Gitsigns next_hunk<CR><CR>", { silent = true, desc = "Gitsigns: Next Hunk" })
vim.keymap.set("n", "[g", "<cmd>Gitsigns prev_hunk<CR><CR>", { silent = true, desc = "Gitsigns: Prev Hunk" })
vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { silent = true, desc = "Gitsigns: Stage Hunk" })
vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { silent = true, desc = "Gitsigns: Reset Hunk" })
vim.keymap.set(
    "n",
    "<leader>gu",
    "<cmd>Gitsigns undo_stage_hunk<CR>",
    { silent = true, desc = "Gitsigns: Unstage Hunk" }
)

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
    silent = true,
    desc = "Packer: Sync",
})

vim.keymap.set("n", "<leader>pc", packer_compile, {
    silent = true,
    desc = "Packer: Compile",
})

-- Hop Mappings
local hop = require("hop")

vim.keymap.set("", "f", function()
    hop.hint_char1({
        current_line_only = false,
    })
end, { silent = true, desc = "Hop: Character" })

-- Hop Bindings
vim.keymap.set("", ";l", "<cmd>HopLineStart<CR>", { silent = true, desc = "Hop: Line Start" })
vim.keymap.set("", ";s", "<cmd>HopPattern<CR>", { silent = true, desc = "Hop: Pattern" })
vim.keymap.set("", ";;", "<cmd>HopWord<CR>", { silent = true, desc = "Hop: Word" })
vim.keymap.set("", ";a", "<cmd>HopAnywhere<CR>", { silent = true, desc = "Hop: Anywhere" })
vim.keymap.set("", ";v", "<cmd>HopVertical<CR>", { silent = true, desc = "Hop Vertical" })

-- Term/Open bindings
vim.keymap.set("n", "<leader><leader>", "<cmd>ToggleTerm<CR>", { silent = true, desc = "Toggle Terminal" })

-- Overseer mappings
wk.register({
    o = {
        name = "Overseer",
    },
}, { prefix = "<leader>" })
vim.keymap.set("n", "<leader>or", vim.cmd.OverseerRun, { silent = true, desc = "Overseer: Run" })
vim.keymap.set("n", "<leader>ot", vim.cmd.OverseerToggle, { silent = true, desc = "Overseer: Toggle" })

vim.keymap.set("v", "<leader>sc", function()
    require("silicon").visualise_api({ to_clip = true })
end, { silent = true, desc = "Silicon: Copy" })
