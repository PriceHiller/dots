local opt = vim.opt

local M = {}

M.setup = function()
    -- Number settings
    opt.number = true
    opt.numberwidth = 2
    opt.relativenumber = true

    -- Scroll Offset
    opt.scrolloff = 3

    -- Disable showmode
    opt.showmode = false

    -- Set truecolor support
    opt.termguicolors = true

    -- Enable system clipboard
    opt.clipboard = "unnamedplus"

    -- Set mouse support for any mode
    opt.mouse = "a"

    -- Allow hidden
    opt.hidden = true

    -- Useful defaults for tab, indentation, etc.
    opt.tabstop = 4
    opt.shiftwidth = 4
    opt.smartindent = true
    opt.breakindent = true
    opt.expandtab = true
    opt.smarttab = true
    opt.shiftround = true

    -- Search settings
    opt.hlsearch = true
    opt.incsearch = true
    opt.ignorecase = true
    opt.smartcase = true

    -- Better backspaces
    opt.backspace = "indent,eol,start"

    -- Make new splits vertical
    opt.splitright = true

    -- Show line & column num of cursor
    opt.ruler = true

    -- Set timeouts
    opt.ttimeoutlen = 20
    opt.timeoutlen = 1000
    opt.updatetime = 250
    opt.signcolumn = "yes"

    -- Enable persistent undo
    opt.undodir = vim.fn.stdpath("cache") .. "/undo"
    opt.undofile = true

    -- Better folding
    opt.foldexpr = "nvim_treesitter#foldexpr()"
    opt.foldmethod = "expr"
    opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
    opt.foldlevel = 20
    vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
    vim.wo.foldmethod = "expr"

    -- Concealment for nicer rendering
    opt.conceallevel = 1
    opt.concealcursor = ""

    -- Cursor line highlight
    opt.cursorline = true

    -- Disable lazy redraw to interact with plugins better
    opt.lazyredraw = false

    -- Spell Settings
    opt.spelllang = { "en_us" }

    -- Better completion experience
    opt.completeopt = "menuone,noselect"

    -- Set max text width
    opt.textwidth = 120

    -- Make statusline global
    opt.laststatus = 3

    -- Set listcharacters
    opt.list = true
    opt.listchars:append("tab:-->")
    opt.listchars:append("lead:⋅")
    opt.listchars:append("trail:·")
    opt.listchars:append("extends:◣")
    opt.listchars:append("precedes:◢")
    opt.listchars:append("nbsp:○")

    -- Set fillchars
    vim.opt.fillchars:append({
        horiz = "━",
        horizup = "┻",
        horizdown = "┳",
        vert = "┃",
        vertleft = "┨",
        vertright = "┣",
        verthoriz = "╋",
    })

    -- Remove end of boundry '~'
    opt.fillchars:append("eob: ")

    -- Allow vim to get settings from file
    opt.modeline = true
    opt.modelines = 5

    -- Set command bar height
    opt.cmdheight = 1

    -- Set splitkeep
    vim.opt.splitkeep = "screen"

    -- Hide the tabline
    vim.opt.showtabline = 0

    -- Improved diff
    opt.diffopt:append("linematch:75")
    opt.fillchars:append("diff:╱")

    -- Limit default menu height for completions
    opt.pumheight = 30

    -- Allow per project configuration via exrc
    opt.exrc = true
end

return M
