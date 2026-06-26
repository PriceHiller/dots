if pcall(require, "blink.cmp") then
    -- Other completion system loaded -- no need to setup fallbacks
    return
end

vim.o.wildmode = "noselect:lastused,full"
vim.o.wildoptions = "pum"

-- Source order in 'complete' (a.k.a. 'cpt') determines popup priority: sources
-- are listed in the order they appear here.
--   . = current buffer, w = other windows, b = loaded buffers, u = unloaded
--   o = 'omnifunc' (set to the LSP source by vim.lsp.completion)
--
-- The per-source match-limit syntax (the "^{count}" suffix, e.g. ".^5") was
-- introduced in Nvim 0.12; on 0.11 it is invalid, so omit it there.
local complete_default, complete_lsp
if vim.fn.has("nvim-0.12") == 1 then
    complete_default = ".^5,w^5,b^5,u^5"
    complete_lsp = "o,.^5,w^5,b^5,u^5"
else
    complete_default = ".,w,b,u"
    complete_lsp = ".,w,b,u"
end

-- Default (no LSP) is buffer-based.
vim.o.complete = complete_default
vim.o.completeopt = "noinsert,menuone,fuzzy,noselect,popup"
vim.o.pumheight = 8
-- 'autocomplete' (Nvim 0.12+) drives native as-you-type completion. On older
-- versions (0.11) the option does not exist, so we fall back to a TextChangedI
-- autocmd that opens the menu manually (see autocomplete fallback below).
local has_native_autocomplete = pcall(vim.api.nvim_get_option_info2, "autocomplete", {})

-- 'autocomplete' is enabled per-buffer (see below), not globally, so that
-- pickers/prompts (snacks, telescope, ...) don't get a native completion popup
-- fighting their own input handling. Default it off globally.
if has_native_autocomplete then
    vim.o.autocomplete = false
end
if vim.fn.exists("*wildtrigger") == 1 then
    vim.api.nvim_create_autocmd("CmdlineChanged", {
        pattern = [=[[:\/\?]]=],
        callback = function()
            vim.fn.wildtrigger()
        end,
    })
else
    vim.o.wildcharm = vim.fn.char2nr(vim.keycode("<C-z>"))
    local grp = vim.api.nvim_create_augroup("cmdline_autocomplete", { clear = true })

    vim.api.nvim_create_autocmd("CmdlineChanged", {
        group = grp,
        callback = function()
            -- only for ':' command-line, not '/' or '?' searches
            if vim.fn.getcmdtype() ~= ":" then
                return
            end

            local line = vim.fn.getcmdline()
            for _, match_to_skip in ipairs({
                "^s*$",
                ".*!$",
                '.*"$',
            }) do
                if line:match(match_to_skip) then
                    return
                end
            end

            -- Nvim 0.11 fallback: feed 'wildcharm' to open the wildmenu live.
            -- Guard against recursion (feeding wildcharm itself fires
            -- CmdlineChanged) and against an already-open wildmenu.
            if vim.fn.wildmenumode() ~= 0 or vim.g._fallback_wildtrigger_busy then
                return
            end
            -- Only trigger while typing at the end of the command (cursor past
            -- the last byte), and skip empty cmdlines. getcmdpos() is 1-based,
            -- so it equals #cmdline + 1 when the cursor is at the end.
            local cmdline = vim.fn.getcmdline()
            if cmdline == "" or vim.fn.getcmdpos() <= #cmdline then
                return
            end
            vim.g._fallback_wildtrigger_busy = true
            vim.api.nvim_feedkeys(vim.keycode("<C-z>"), "n", false)
            vim.schedule(function()
                vim.g._fallback_wildtrigger_busy = false
            end)
        end,
    })
end

--- Whether the fallback completion machinery (autocomplete + <CR> accept)
--- should apply to a buffer. Generic conditions (à la blink's is_enabled),
--- not a filetype allowlist: pickers/prompts use a non-empty buftype (often
--- 'prompt') and/or set `vim.b.completion = false`.
local function completion_should_attach(buf)
    if vim.b[buf].completion == false then
        return false
    end
    -- Only ordinary editable buffers.
    return vim.bo[buf].buftype == ""
end

-- Enable native autocomplete only in ordinary buffers.
local autocomplete_group = vim.api.nvim_create_augroup("fallback_completion_autocomplete", { clear = true })

if has_native_autocomplete then
    vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile", "FileType" }, {
        group = autocomplete_group,
        callback = function(args)
            vim.bo[args.buf].autocomplete = completion_should_attach(args.buf)
        end,
    })
else
    -- Fallback for Nvim < 0.12 (no 'autocomplete' option): emulate as-you-type
    -- completion by opening the popup menu on TextChangedI when the cursor
    -- follows a keyword character. Pum navigation (CTRL-N/P) is non-destructive
    -- because 'completeopt' has "noinsert,noselect".
    vim.api.nvim_create_autocmd("TextChangedI", {
        group = autocomplete_group,
        callback = function(args)
            if not completion_should_attach(args.buf) then
                return
            end
            -- Don't retrigger while the menu is already open (it refreshes itself),
            -- and don't fight an active snippet expansion.
            if vim.fn.pumvisible() ~= 0 then
                return
            end
            -- Only trigger after a keyword character to avoid popping up on
            -- whitespace/punctuation.
            local col = vim.fn.col(".") - 1
            if col <= 0 then
                return
            end
            local char = vim.fn.getline("."):sub(col, col)
            if not char:match("[%w_]") then
                return
            end
            -- Open the menu from the configured 'complete' sources without
            -- inserting text. Feed as untranslated keys; this is a no-op if no
            -- matches are produced.
            vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
        end,
    })
end

-- Enable LSP-driven completion for every buffer an LSP client attaches to.
-- autotrigger mirrors blink's behaviour of triggering on server-defined triggerCharacters.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        if not completion_should_attach(args.buf) then
            return
        end
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
            -- Prioritise LSP results over buffer words. The "o" flag pulls
            -- matches from 'omnifunc' (which vim.lsp.completion sets to
            -- v:lua.vim.lsp.omnifunc); listing it first in 'complete' makes
            -- LSP candidates rank above the buffer/window/buffer-list sources.
            vim.bo[args.buf].complete = complete_lsp
        end
    end,
})

-- Restore the buffer-only 'complete' order once the last LSP client detaches,
-- so buffers without an LSP don't keep an "o" source pointing at a stale
-- omnifunc.
vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(args)
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(args.buf) then
                return
            end
            local remaining = vim.lsp.get_clients({ bufnr = args.buf })
            -- The detaching client may still be listed; exclude it.
            local has_completion_client = false
            for _, client in ipairs(remaining) do
                if client.id ~= args.data.client_id and client:supports_method("textDocument/completion") then
                    has_completion_client = true
                    break
                end
            end
            if not has_completion_client then
                vim.bo[args.buf].complete = complete_default
            end
        end)
    end,
})

-- Trigger: <C-space> = { "show", ... }
vim.keymap.set("i", "<C-Space>", "<C-n>", {
    silent = true,
    noremap = true,
    desc = "Completion: Trigger",
})
vim.keymap.set("c", "<C-Space>", "<Tab>", {
    silent = true,
    noremap = true,
    desc = "Completion: Trigger (cmdline)",
})

--- Commandline bindings
for _, next_bind in ipairs({
    "<Tab>",
}) do
    vim.keymap.set("c", next_bind, function()
        return vim.fn.wildmenumode() == 1 and "<C-n>" or next_bind
    end, { expr = true, desc = "Completion: Next" })
end

for _, prev_bind in ipairs({
    "<S-Tab>",
}) do
    vim.keymap.set("c", prev_bind, function()
        return vim.fn.wildmenumode() == 1 and "<C-p>" or prev_bind
    end, { expr = true, desc = "Completion: Previous" })
end

-- Insert mode bindings
for _, next_bind in ipairs({
    "<Tab>",
}) do
    vim.keymap.set("i", next_bind, function()
        return vim.fn.pumvisible() ~= 0 and "<C-n>" or next_bind
    end, { silent = true, expr = true, noremap = true, desc = "Completion: Next" })
end

for _, prev_bind in ipairs({
    "<S-Tab>",
}) do
    vim.keymap.set("i", prev_bind, function()
        return vim.fn.pumvisible() ~= 0 and "<C-p>" or prev_bind
    end, { silent = true, expr = true, noremap = true, desc = "Completion: Previous" })
end

-- Accept: <CR> = { "accept", "fallback" }
-- Note: <C-e> = { "hide", "fallback" } is already native pum behaviour
--
-- This mirrors how blink.cmp coexists with other <CR> owners:
--   1. It only attaches in "ordinary" buffers (see completion_should_attach):
--      pickers/prompts own <CR> for "confirm selection".
--   2. When it does not accept a completion, it delegates to whatever <CR>
--      mapping currently exists (buffer-local first, then global) rather than
--      assuming a literal <CR>. That way autopairs' <CR> (bracket splitting)
--      and unknown pickers all keep working, with no plugin-specific `require`.

--- Find the insert-mode <CR> mapping that would be active if ours did not
--- exist: a non-ours buffer-local map wins, otherwise the global map.
local function find_underlying_cr()
    for _, scope in ipairs({
        vim.api.nvim_buf_get_keymap(0, "i"),
        vim.api.nvim_get_keymap("i"),
    }) do
        for _, map in ipairs(scope) do
            if (map.lhs == "<CR>" or map.lhs == "\r") and map.desc ~= "Completion: Accept or CR" then
                return map
            end
        end
    end
end

--- Resolve what <CR> should produce when the popup menu is NOT visible by
--- delegating to the underlying <CR> mapping (autopairs, a picker, ...).
local function fallback_keys()
    local map = find_underlying_cr()
    if map then
        if type(map.callback) == "function" then
            if map.expr == 1 then
                local ok, result = pcall(map.callback)
                if ok and type(result) == "string" and result ~= "" then
                    return map.noremap == 1 and vim.keycode(result) or result
                end
            else
                -- Non-expr callback: run it for its side effects, insert nothing.
                vim.schedule(map.callback)
                return ""
            end
        elseif map.rhs and map.rhs ~= "" then
            -- A plain rhs mapping (commonly <Plug>/<Cmd>); feed it through.
            return map.noremap == 1 and map.rhs or vim.keycode(map.rhs)
        end
    end
    return vim.keycode("<CR>")
end

vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter" }, {
    group = vim.api.nvim_create_augroup("fallback_completion_cr", { clear = true }),
    callback = function(args)
        local buf = args.buf
        if not completion_should_attach(buf) then
            return
        end

        vim.keymap.set("i", "<CR>", function()
            if vim.fn.pumvisible() ~= 0 then
                return vim.keycode("<C-y>")
            end
            return fallback_keys()
        end, {
            buffer = buf,
            silent = true,
            expr = true,
            noremap = true,
            replace_keycodes = false,
            desc = "Completion: Accept or CR",
        })
    end,
})

-- Snippets: <C-Tab> = { "snippet_forward", "fallback" }
vim.keymap.set({ "i", "s" }, "<C-Tab>", function()
    if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
    end
end, { silent = true, desc = "Snippet: Forward" })

-- Snippets: <C-S-Tab> = { "snippet_backward", "fallback" }
vim.keymap.set({ "i", "s" }, "<C-S-Tab>", function()
    if vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
    end
end, { silent = true, desc = "Snippet: Backward" })

-- Keep the popup menu below the cursor line.
--
-- When the cursor sits near the bottom of the window there isn't room for the
-- (up to 'pumheight') popup below it, so Neovim flips the menu *above* the
-- cursor, covering the line being edited. Temporarily raising 'scrolloff' to at
-- least 'pumheight' while the menu is open forces the view to scroll so there's
-- always room below; we restore the user's value once completion ends.
local pum_scroll = vim.api.nvim_create_augroup("fallback_completion_pum_scroll", { clear = true })
local saved_scrolloff = nil

vim.api.nvim_create_autocmd("CompleteChanged", {
    group = pum_scroll,
    callback = function()
        if saved_scrolloff == nil then
            saved_scrolloff = vim.wo.scrolloff
        end
        local needed = vim.o.pumheight > 0 and vim.o.pumheight or 8
        if vim.wo.scrolloff < needed then
            vim.wo.scrolloff = needed
        end
    end,
})

vim.api.nvim_create_autocmd("CompleteDone", {
    group = pum_scroll,
    callback = function()
        if saved_scrolloff ~= nil then
            vim.wo.scrolloff = saved_scrolloff
            saved_scrolloff = nil
        end
    end,
})
