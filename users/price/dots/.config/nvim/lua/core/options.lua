local opt = vim.opt

local M = {}

M.setup = function()
    -- Number settings
    opt.number = true
    opt.numberwidth = 2
    opt.relativenumber = true

    -- Scroll Offset
    opt.scrolloff = 3
    opt.sidescrolloff = 5

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
    opt.expandtab = true
    opt.smarttab = true
    opt.shiftround = true

    -- Wrapping behavior
    opt.wrap = true
    opt.breakat = " \t;,[]()"
    opt.linebreak = true
    opt.breakindent = true
    opt.breakindentopt = "list:-1"

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
    opt.timeout = true
    opt.ttimeoutlen = 20
    opt.timeoutlen = 1000
    opt.updatetime = 1000

    -- Enable persistent undo
    opt.undofile = true

    -- Better folding
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            if not (pcall(vim.treesitter.start)) then
                return
            end
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.opt_local.foldmethod = "expr"
        end,
    })
    opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
    vim.o.foldcolumn = "auto"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Concealment for nicer rendering
    opt.conceallevel = 2
    opt.concealcursor = ""

    -- Cursor line highlight
    opt.cursorline = true

    -- Disable lazy redraw to interact with plugins better
    opt.lazyredraw = false

    -- Spell Settings
    opt.spelllang = { "en_us" }

    -- Better completion experience
    opt.completeopt = "menuone,noselect"

    -- Make statusline global
    opt.laststatus = 3

    -- Set listcharacters
    opt.list = true
    opt.listchars:append("tab:  ")
    opt.listchars:append("trail:·")
    opt.listchars:append("extends:◣")
    opt.listchars:append("precedes:◢")
    opt.listchars:append("nbsp:○")

    -- Set fillchars
    vim.opt.fillchars:append({
        horiz = "─",
        horizup = "┴",
        horizdown = "┬",
        vert = "│",
        vertleft = "┤",
        vertright = "├",
        verthoriz = "┼",
    })

    -- Remove end of boundry '~'
    opt.fillchars:append("eob: ")

    -- Allow vim to get settings from file
    opt.modeline = true
    opt.modelines = 5

    -- Set splitkeep
    vim.opt.splitkeep = "cursor"

    -- Hide the tabline
    vim.opt.showtabline = 0

    -- Improved diffopt
    opt.diffopt = ""
    for _, new_diffopt in ipairs({
        "followwrap",
        "internal",
        "filler",
        "closeoff",
        "indent-heuristic",
        "inline:word",
        "linematch:60",
        "algorithm:histogram",
    }) do
        ---@diagnostic disable-next-line: undefined-field
        opt.diffopt:append(new_diffopt)
    end
    opt.fillchars:append("diff:╱")

    -- Limit default menu height for completions
    opt.pumheight = 15

    -- Allow per project configuration via exrc
    opt.exrc = true

    -- Improve jumplist behavior to restore marks
    opt.jumpoptions:append("view")

    -- When closing a tab, go to the previously used tab page
    opt.tabclose = "uselast"

    -- Make terminal cursor in insert mode a vertical line
    opt.guicursor:append("t:ver25")

    -- More lines in scrollback for terminal buffers
    opt.scrollback = 100000

    -- Improved shada options
    opt.shada = {
        "!",
        -- Remember more files for marks & oldfiles
        "'1000",
        -- Remember up to 100 lines per register
        "<100",
        "s10",
        "h",
    }

    -- Default textwidth, particuarly relevant for automatically hard wrapping comments when
    -- `formatoptions` contains `c`
    opt.textwidth = 80
    -- Relevant for `n` in 'formatoptions'
    opt.formatlistpat = require("utils.formatpat").new():listpat()
    opt.formatoptions = "jcroqnp"
end

return M
