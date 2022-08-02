local cmp = require('cmp')
local types = require('cmp.types')
local str = require('cmp.utils.str')
local compare = cmp.config.compare
local luasnip = require('luasnip')

local kind_icons = {
    Text = '',
    Method = '',
    Function = '',
    Constructor = '',
    Field = '',
    Variable = '',
    Class = 'ﴯ',
    Interface = '',
    Module = '',
    Property = 'ﰠ',
    Unit = '',
    Value = '',
    Enum = '',
    Keyword = '',
    Snippet = '',
    Color = '',
    File = '',
    Reference = '',
    Folder = '',
    EnumMember = '',
    Constant = '',
    Struct = '',
    Event = '',
    Operator = '',
    TypeParameter = '',
}

-- Load Snippets
require('luasnip.loaders.from_vscode').lazy_load()

local border = {
    { '╭', 'CmpBorder' },
    { '─', 'CmpBorder' },
    { '╮', 'CmpBorder' },
    { '│', 'CmpBorder' },
    { '╯', 'CmpBorder' },
    { '─', 'CmpBorder' },
    { '╰', 'CmpBorder' },
    { '│', 'CmpBorder' },
}

cmp.setup({
    formatting = {
        fields = {
            cmp.ItemField.Kind,
            cmp.ItemField.Abbr,
            cmp.ItemField.Menu,
        },
        format = function(entry, vim_item)
            -- Get the full snippet (and only keep first line)
            local word = entry:get_insert_text()
            if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
                word = vim.lsp.util.parse_snippet(word)
            end
            word = str.oneline(word)

            -- concatenates the string
            local max = 50
            if string.len(word) >= max then
                local before = string.sub(word, 1, math.floor((max - 3) / 2))
                word = before .. '...'
            end

            if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet
                and string.sub(vim_item.abbr, -1, -1) == '~'
            then
                word = word .. '~'
            end
            vim_item.abbr = word
            -- Kind icons
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            -- Source
            vim_item.menu = ({
                fuzzy_buffer = '[Buffer]',
                nvim_lsp = '[Lsp]',
                luasnip = '[LuaSnip]',
                path = '[Path]',
                calc = '[Calculator]',
                neorg = '[Neorg]',
                emoji = '[Emoji]',
                zsh = '[Zsh]',
                crates = '[Crates]',
                cmdline_history = '[Cmd History]',
                rg = '[Ripgrep]',
                npm = '[Npm],',
                conventionalcommits = '[Commit]',
            })[entry.source.name]
            return vim_item
        end,
    },
    window = {
        documentation = {
            border = border,
        },
        completion = {
            border = border,
        },
    },
    experimental = {
        ghost_text = true,
        native_menu = false,
    },
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<C-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp', priority = 10 },
        { name = 'luasnip', priority = 9 }, -- For luasnip users.
        { name = 'fuzzy_buffer', priority = 8 },
        { name = 'rg', priority = 7 },
        { name = 'path', priority = 6 },
        { name = 'zsh', priority = 5 },
        { name = 'emoji', keyword_length = 2 },
        { name = 'neorg' },
        { name = 'calc' },
        { name = 'npm', keyword_length = 2 },
        {
            name = 'dictionary',
            keyword_length = 2,
        },
    }),
    sorting = {
        comparators = {
            compare.score,
            compare.offset,
            compare.recently_used,
            compare.exact,
            require('cmp_fuzzy_buffer.compare'),
            compare.kind,
            compare.sort_text,
            compare.length,
            compare.order,
        },
    },
})

-- Git Commit Completions
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'conventionalcommits', priority = 20 },
    }),
})

cmp.setup.filetype('NeogitCommitMesssage', {
    sources = cmp.config.sources({
        { name = 'conventionalcommits', priority = 20 },
    }),
})

cmp.setup.filetype('toml', {
    sources = cmp.config.sources({
        { name = 'crates' },
    }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'fuzzy_buffer' },
        { name = 'cmdline_history' },
    }),
})

cmp.setup.cmdline('?', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'fuzzy_buffer' },
        { name = 'cmdline_history' },
    }),
})

cmp.setup.cmdline('@', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'fuzzy_buffer' },
        { name = 'cmdline_history' },
    }),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' },
        { name = 'cmdline_history' },
    }),
})
