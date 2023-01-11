-- Packer strap, install packer automatically and configure plugins
-- See the end of this file for how the variable `packer_strap` gets used
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.notify("Installing Lazy plugin manager, please wait...")
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

local lazy = require("lazy")

lazy.setup({
    -- Commonly used library
    {
        "nvim-lua/plenary.nvim",
        event = "VeryLazy",
    },

    -- Much nicer ui, integrates cmdheight = 0 wella
    -- NOTE: Temporarily disabling this until nightly is fixed
    -- {
    --     "folke/noice.nvim",
    --     event = "VeryLazy",
    --     config = function()
    --         -- NOTE: Might be redundant, to check later
    --         require("plugins.configs.nvim-notify")
    --         require("plugins.configs.noice")
    --     end,
    --     dependencies = {
    --         -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    --         "MunifTanjim/nui.nvim",
    --         "rcarriga/nvim-notify",
    --         "hrsh7th/nvim-cmp",
    --     },
    -- },
    --
    { "rcarriga/nvim-notify" },

    -- Color schemes
    { "folke/tokyonight.nvim" },
    {
        "EdenEast/nightfox.nvim",
        event = "VeryLazy",
        config = function()
            require("nightfox").setup({
                options = {
                    transparent = true,
                    dim_inactive = true,
                },
            })
        end,
    },
    {
        "rebelot/kanagawa.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.kanagawa")
        end,
    },

    -- Icons for folders, files, etc.
    {
        "kyazdani42/nvim-web-devicons",
        event = "VeryLazy",
    },

    -- Statusline.
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.statusline")
        end,
    },

    -- Indentation Guides
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.indent-blankline")
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        build = ":TSUpdate",
        dependencies = {
            "p00f/nvim-ts-rainbow",
            "nvim-treesitter/nvim-treesitter-context",
        },
        config = function()
            require("plugins.configs.treesitter")
        end,
        -- before = "folke/noice.nvim",
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "VeryLazy",
        after = { "nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        disable = function(lang, bufnr)
                            local mode = vim.fn.mode()
                            if mode == "c" then
                                return true
                            end
                        end,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["ib"] = "@block.inner",
                            ["ab"] = "@block.outer",
                        },
                    },
                    move = {
                        enable = true,
                        disable = function(lang, bufnr)
                            local mode = vim.fn.mode()
                            if mode == "c" then
                                return true
                            end
                        end,
                        set_jumps = true,
                        goto_next_start = {
                            ["]fs"] = "@function.outer",
                            ["]cs"] = "@class.outer",
                            ["]bs"] = "@block.outer",
                        },
                        goto_next_end = {
                            ["]fe"] = "@function.outer",
                            ["]ce"] = "@class.outer",
                            ["]be"] = "@block.outer",
                        },
                        goto_previous_start = {
                            ["[fs"] = "@function.outer",
                            ["[cs"] = "@class.outer",
                            ["[bs"] = "@block.outer",
                        },
                        goto_previous_end = {
                            ["[fe"] = "@function.outer",
                            ["[ce"] = "@class.outer",
                            ["[bs"] = "@block.outer",
                        },
                    },
                },
            })
        end,
    },

    -- Highlight given color codes
    {
        "brenoprata10/nvim-highlight-colors",
        event = "VeryLazy",
        config = function()
            require("nvim-highlight-colors").setup({
                enable_tailwind = true,
                render = "background",
            })
        end,
    },

    -- Dashboard when no file is given to nvim

    {
        "goolord/alpha-nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("plugins.configs.alpha")
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-telescope/telescope-media-files.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
            "artart222/telescope_find_directories",
            "nvim-telescope/telescope-ui-select.nvim",
            "debugloop/telescope-undo.nvim",
            { "nvim-telescope/telescope-smart-history.nvim", dependencies = "tami5/sqlite.lua" },
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("plugins.configs.telescope-nvim")
        end,
    },

    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
    },

    -- File Tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        event = "VeryLazy",
        branch = "v2.x",
        dependencies = {
            "kyazdani42/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("plugins.configs.neotree")
        end,
        cmd = "Neotree",
    },

    -- Lspconfig
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "folke/neodev.nvim",
            "Decodetalkers/csharpls-extended-lsp.nvim",
            "williamboman/mason-lspconfig.nvim",
            "nanotee/sqls.nvim",
            "williamboman/mason.nvim",
            "simrat39/rust-tools.nvim",
            "Hoffs/omnisharp-extended-lsp.nvim",
            "b0o/schemastore.nvim",
        },
        -- after = "noice.nvim",
        config = function()
            require("mason").setup({})
            require("plugins.configs.lsp")
        end,
    },

    -- Incremental rename, easier to view renames
    {
        "smjonas/inc-rename.nvim",
        event = "VeryLazy",
        config = function()
            require("inc_rename").setup({})
        end,
    },

    -- Better LSP Virtual Text Lines
    {
        url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        event = "VeryLazy",
        config = function()
            require("lsp_lines").setup()
        end,
    },

    -- Lsp From Null LS
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.null_ls")
        end,
    },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "VeryLazy",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },

    -- Snippets
    {
        "rafamadriz/friendly-snippets",
        event = "VeryLazy",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        after = "LuaSnip",
    },

    -- Code completion
    {
        "hrsh7th/nvim-cmp",
        event = "VeryLazy",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-emoji",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "hrsh7th/cmp-calc",
            "davidsierradz/cmp-conventionalcommits",
            "tamago324/cmp-zsh",
            "dmitmel/cmp-cmdline-history",
            "David-Kunz/cmp-npm",
            "lukas-reineke/cmp-rg",
            "onsails/lspkind.nvim",
            "f3fora/cmp-spell",
        },
        config = function()
            require("plugins.configs._cmp")
        end,
    },

    {
        "tzachar/cmp-fuzzy-buffer",
        event = "VeryLazy",
        dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
    },
    { "tzachar/cmp-fuzzy-path", dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" } },
    {
        "saecki/crates.nvim",
        event = "VeryLazy",
        dependencies = { { "nvim-lua/plenary.nvim" } },
        config = function()
            require("crates").setup()
        end,
    },

    -- DAP, debugger
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        config = function()
            require("dap.ext.vscode").load_launchjs()
            require("plugins.configs._dap")
        end,
        after = "nvim-notify",
    },

    -- Python debugger, dapinstall does not play nice with debugpy
    {
        "mfussenegger/nvim-dap-python",
        event = "VeryLazy",
        after = "nvim-dap",
        config = function()
            require("plugins.configs.python-dap")
        end,
    },

    -- Virtual Text for DAP
    {
        "theHamsta/nvim-dap-virtual-text",
        event = "VeryLazy",
        after = "nvim-dap",
        config = function()
            require("nvim-dap-virtual-text").setup({})
        end,
    },

    -- Fancy ui for dap
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        after = "nvim-dap",
        config = function()
            require("plugins.configs.dap-ui")
        end,
    },

    -- Code formatting
    {
        "sbdchd/neoformat",
        event = "VeryLazy",
        cmd = "Neoformat",
        config = function()
            require("plugins.configs.neoformat")
        end,
    },

    {
        "anuvyklack/pretty-fold.nvim",
        event = "VeryLazy",
        dependencies = "anuvyklack/nvim-keymap-amend",
        config = function()
            require("pretty-fold").setup({
                fill_char = " ",
            })
        end,
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        config = function()
            require("gitsigns").setup({
                current_line_blame = true,
                current_line_blame_opts = {
                    delay = 0,
                },
            })
        end,
    },

    -- Highlight certain comments, TODO, BUG, etc.
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        config = function()
            require("todo-comments").setup({})
        end,
    },

    -- Show possible key bindings during typing
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({})
        end,
    },

    -- Create full path if not existing on write
    {
        "jghauser/mkdir.nvim",
        event = "VeryLazy",
        config = function()
            require("mkdir")
        end,
    },

    -- Text commenting
    {
        "terrortylor/nvim-comment",
        event = "VeryLazy",
        cmd = "CommentToggle",
        config = function()
            require("nvim_comment").setup()
        end,
    },

    -- Move selections with alt+movement key
    {
        "matze/vim-move",
        event = "VeryLazy",
    },

    -- Register support in telescope with persistent save
    {
        "AckslD/nvim-neoclip.lua",
        event = "VeryLazy",
        dependencies = {
            { "tami5/sqlite.lua", module = "sqlite" },
            { "nvim-telescope/telescope.nvim" },
        },
        config = function()
            require("neoclip").setup({
                enable_persistent_history = true,
            })
        end,
    },

    -- Markdown Previewer
    {
        "iamcco/markdown-preview.nvim",
        event = "VeryLazy",
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_browser = "firefox-developer-edition"
        end,
        ft = { "markdown" },
    },

    -- Better Git integration
    {
        "TimUntersberger/neogit",
        event = "VeryLazy",
        config = function()
            require("neogit").setup({
                disable_commit_confirmation = true,
                integrations = {
                    diffview = true,
                },
            })
        end,
        event = "VeryLazy",
        dependencies = {
            "sindrets/diffview.nvim",
        },
    },

    -- Ansible Syntax Highlighting
    {
        "pearofducks/ansible-vim",
        event = "VeryLazy",
    },

    -- Better search display
    {
        "kevinhwang91/nvim-hlslens",
        event = "VeryLazy",
        module = "hlslens",
        keys = "/",
        config = function()
            require("hlslens").setup()
        end,
    },

    -- Note Taking
    {
        "nvim-neorg/neorg",
        config = function()
            require("plugins.configs._neorg")
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neorg/neorg-telescope",
        },
        after = "nvim-treesitter",
        ft = "norg",
    },

    -- Log Syntax Highlighting
    {
        "MTDL9/vim-log-highlighting",
        event = "VeryLazy",
    },

    -- Lots of small modules pulled into
    -- one git repository
    {
        "echasnovski/mini.nvim",
        event = "VeryLazy",
        config = function()
            require("mini.cursorword").setup({})
        end,
    },

    -- Smoother Scrolling
    {
        "karb94/neoscroll.nvim",
        event = "VeryLazy",
        config = function()
            require("neoscroll").setup({
                easing_function = "circular",
            })
        end,
    },

    -- Generate function/class/etc annotations
    {
        "danymat/neogen",
        event = "VeryLazy",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require("neogen").setup({
                snippet_engine = "luasnip",
                languages = {
                    cs = {
                        template = {
                            annotation_convention = "xmldoc",
                        },
                    },
                },
            })
        end,
    },

    -- Multiple cursor/multiple visual selection support
    {
        "mg979/vim-visual-multi",
        event = "VeryLazy",
    },

    -- Editorconfig support
    {
        "gpanders/editorconfig.nvim",
        event = "VeryLazy",
    },

    -- Maintain last cursor position in files
    {
        "ethanholz/nvim-lastplace",
        event = "VeryLazy",
        config = function()
            require("nvim-lastplace").setup({
                lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit", "fugitive" },
                lastplace_open_folds = true,
            })
        end,
    },

    -- Diagnose startup time
    { "dstein64/vim-startuptime" },

    -- More codeactions
    {
        "ThePrimeagen/refactoring.nvim",
        event = "VeryLazy",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-treesitter/nvim-treesitter" },
        },
    },

    -- Http Request Support
    {
        "NTBBloodbath/rest.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local rest_nvim = require("rest-nvim")
            rest_nvim.setup({
                -- This is a dev plugin, makes life easier
                skip_ssl_verification = true,
            })
        end,
    },

    -- Allows repeating actions and more
    {
        "anuvyklack/hydra.nvim",
        event = "VeryLazy",
        dependencies = {
            "anuvyklack/keymap-layer.nvim",
            "lewis6991/gitsigns.nvim",
            "jbyuki/venn.nvim",
            "folke/which-key.nvim",
        },
        config = function()
            require("plugins.configs.hydra")
        end,
    },

    -- Faster motions
    {
        "phaazon/hop.nvim",
        event = "VeryLazy",
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
        end,
    },

    -- Surround actions
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },

    -- Better list continuation
    {
        "gaoDean/autolist.nvim",
        event = "VeryLazy",
        ft = {
            "markdown",
            "text",
            "text",
            "plaintex",
        },
        config = function()
            require("autolist").setup({})
        end,
    },

    -- Tint inactive windows
    {
        "levouh/tint.nvim",
        event = "VeryLazy",
        config = function()
            require("tint").setup({
                highlight_ignore_patterns = { "WinSeparator" },
                tint = -30,
                saturation = 0.8,
            })
        end,
    },

    -- Highlight argument definitions and usages
    {
        "m-demare/hlargs.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("hlargs").setup({})
        end,
    },

    -- Vim Latex Support
    {
        "lervag/vimtex",
        event = "VeryLazy",
        ft = "tex",
        config = function()
            vim.g.vimtext_view_method = "zathura"
            vim.g.vimtex_view_general_viewer = "zathura"
        end,
    },

    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        config = function()
            require("toggleterm").setup({
                start_in_insert = false,
                direction = "float",
                autochdir = true,
                winbar = {
                    enable = true,
                    name_formatter = function(term) --  term: Terminal
                        return term.name
                    end,
                },
            })
        end,
        cmd = {
            "ToggleTerm",
            "ToggleTermSetName",
            "ToggleTermToggleAll",
            "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualLines",
            "ToggleTermSendVisualSelection",
        },
    },

    -- Take a screenshot of code selected
    {
        "NarutoXY/silicon.lua",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("silicon").setup({})
        end,
    },

    -- Nice sidebar cursor goodies
    {
        "gen740/SmoothCursor.nvim",
        event = "VeryLazy",
        after = "kanagawa.nvim",
        config = function()
            require("smoothcursor").setup({
                fancy = {
                    enable = true,
                    head = { cursor = "⯈", texthl = "SmoothCursorCursor", linehl = nil },
                    body = {
                        { cursor = "", texthl = "SmoothCursorTrailBig1" },
                        { cursor = "", texthl = "SmoothCursorTrailBig2" },
                        { cursor = "●", texthl = "SmoothCursorTrailMedium" },
                        { cursor = "●", texthl = "SmoothCursorTrailMedium" },
                        { cursor = "•", texthl = "SmoothCursorTrailSmall" },
                        { cursor = ".", texthl = "SmoothCursorTrailXSmall" },
                        { cursor = ".", texthl = "SmoothCursorTrailXSmall" },
                    },
                },
                disabled_filetypes = { "NeogitNotification" },
            })
        end,
    },

    -- Color Picker
    {
        "uga-rosa/ccc.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.ccc")
        end,
        cmd = {
            "CccPick",
            "CccConvert",
            "CccHighlighterEnable",
            "CccHighlighterToggle",
            "CccHighlighterDisable",
        },
    },

    -- Task runner & job management
    {
        "stevearc/overseer.nvim",
        event = "VeryLazy",
        config = function()
            require("overseer").setup()
        end,
    },

    -- Better buffer deletion
    {
        "famiu/bufdelete.nvim",
        event = "VeryLazy",
    },
}, {
    checker = {
        enabled = true,
        concurrency = 20,
    },
    lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})
