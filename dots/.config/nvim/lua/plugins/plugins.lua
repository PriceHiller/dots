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
    -- Lazy itself
    { "folke/lazy.nvim" },

    -- Commonly used library
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    },

    -- Much nicer ui, integrates cmdheight = 0 wella
    {
        "folke/noice.nvim",
        config = function()
            -- NOTE: Might be redundant, to check later
            require("plugins.configs.nvim-notify")
            require("plugins.configs.noice")
        end,
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
            "hrsh7th/nvim-cmp",
        },
    },

    -- Color schemes
    {
        "rebelot/kanagawa.nvim",
        build = function()
            require("plugins.configs.kanagawa")
            vim.cmd.KanagawaCompile()
        end,
        config = function()
            require("plugins.configs.kanagawa")
            vim.cmd.colorscheme("kanagawa")
            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = "lua/plugins/configs/kanagawa.lua",
                callback = function()
                    vim.schedule(vim.cmd.KanagawaCompile)
                end,
            })
        end,
    },

    -- Icons for folders, files, etc.
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
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
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-context",
            "nvim-treesitter/playground",
            "windwp/nvim-ts-autotag",
            "nvim-treesitter/nvim-treesitter-textobjects",
            { "pfeiferj/nvim-hurl", opts = {}, dev = true },
        },
        config = function()
            require("plugins.configs.treesitter")
        end,
    },

    -- Rainbow braces/brackets/etc
    {
        url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
        config = function()
            local rainbow_delimiters = require("rainbow-delimiters")
            vim.g.rainbow_delimiters = {
                strategy = {
                    on_attach = function()
                        if vim.fn.line("$") > 10000 then
                            return nil
                        elseif vim.fn.line("$") > 1000 then
                            return rainbow_delimiters.strategy["global"]
                        end
                        return rainbow_delimiters.strategy["local"]
                    end,
                },
                query = {
                    [""] = "rainbow-delimiters",
                    lua = "rainbow-blocks",
                    latex = "rainbow-blocks",
                    html = "rainbow-blocks",
                    javascript = "rainbow-delimiters-react",
                    tsx = "rainbow-parens",
                    verilog = "rainbow-blocks",
                },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            }
        end,
    },

    -- Dashboard when no file is given to nvim
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("plugins.configs.alpha")
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        cmd = {
            "Telescope",
        },
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
        branch = "v2.x",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
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
        dependencies = {
            "folke/neodev.nvim",
            "Decodetalkers/csharpls-extended-lsp.nvim",
            "williamboman/mason-lspconfig.nvim",
            "williamboman/mason.nvim",
            "simrat39/rust-tools.nvim",
            "Hoffs/omnisharp-extended-lsp.nvim",
            "b0o/schemastore.nvim",

            {
                "pmizio/typescript-tools.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
        },
        config = function()
            require("mason").setup({})
            require("plugins.configs.lsp")
        end,
    },

    -- Show code actions
    {
        "kosayoda/nvim-lightbulb",
        dependencies = {
            "antoinemadec/FixCursorHold.nvim",
        },
        config = function()
            local text_icon = ""
            local nvim_lightbulb = require("nvim-lightbulb")
            nvim_lightbulb.setup({
                sign = {
                    priority = 9,
                    text = text_icon
                },
            })
            vim.fn.sign_define(
                "LightBulbSign",
                { text = text_icon, numhl = "DiagnosticSignHint", texthl = "DiagnosticSignHint", priority = 9 }
            )
            vim.api.nvim_create_autocmd("CursorHold,CursorHoldI", {
                callback = nvim_lightbulb.update_lightbulb,
            })
        end,
    },

    -- Incremental rename, easier to view renames
    {
        "smjonas/inc-rename.nvim",
        event = "VeryLazy",
        opts = {},
    },

    -- Better LSP Virtual Text Lines
    {
        url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        event = "VeryLazy",
        opts = {},
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
        opts = {},
    },

    -- Code completion
    {
        "hrsh7th/nvim-cmp",
        event = "VeryLazy",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
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
            "FelipeLema/cmp-async-path",
            -- Snippets
            {
                "L3MON4D3/LuaSnip",
                build = "make install_jsregexp",
                event = "VeryLazy",
                dependencies = {
                    "rafamadriz/friendly-snippets",
                    "saadparwaiz1/cmp_luasnip",
                },
            },
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
    {
        "saecki/crates.nvim",
        dependencies = { { "nvim-lua/plenary.nvim" } },
        ft = "toml",
        opts = {},
    },

    -- DAP, debugger
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        config = function()
            require("dap.ext.vscode").load_launchjs()
            require("plugins.configs._dap")
        end,
    },

    -- Python debugger, dapinstall does not play nice with debugpy
    {
        "mfussenegger/nvim-dap-python",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.python-dap")
        end,
    },

    -- Virtual Text for DAP
    {
        "theHamsta/nvim-dap-virtual-text",
        event = "VeryLazy",
        opts = {},
    },

    -- Fancy ui for dap
    {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        config = function()
            require("plugins.configs.dap-ui")
        end,
    },

    -- Code formatting
    {
        "sbdchd/neoformat",
        cmd = "Neoformat",
        config = function()
            require("plugins.configs.neoformat")
        end,
    },

    {
        "luukvbaal/statuscol.nvim",
        event = "VeryLazy",
        config = function()
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                foldfunc = "builtin",
                setopt = true,
                relculright = false,
                segments = {
                    { text = { "%s" }, click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
                },
            })
        end,
    },

    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        event = "VeryLazy",
        config = function()
            require("plugins.configs.nvim-ufo")
        end,
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 0,
            },
        },
    },

    -- Highlight certain comments, TODO, BUG, etc.
    {
        "folke/todo-comments.nvim",
        cmd = {
            "TodoTrouble",
        },
        opts = {},
    },

    -- Show possible key bindings during typing
    {
        "folke/which-key.nvim",
        lazy = true,
        opts = {},
    },

    -- Create full path if not existing on write
    {
        "jghauser/mkdir.nvim",
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
            { "tami5/sqlite.lua" },
            { "nvim-telescope/telescope.nvim" },
        },
        opts = {
            enable_persistent_history = true,
        },
    },

    -- Markdown Previewer
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_browser = "firefox-developer-edition"
        end,
        ft = { "markdown" },
    },

    -- Better Git integration
    {
        "NeogitOrg/neogit",
        lazy = true,
        opts = {
            disable_commit_confirmation = true,
            integrations = {
                diffview = true,
            },
        },
        dependencies = {
            "sindrets/diffview.nvim",
            opts = {
                enhanced_diff_hl = true,
            },
        },
    },

    {
        "tpope/vim-fugitive",
        event = "VeryLazy",
    },

    -- Better search display
    {
        "kevinhwang91/nvim-hlslens",
        event = "VeryLazy",
        opts = {},
    },

    -- Log Syntax Highlighting
    {
        "MTDL9/vim-log-highlighting",
        event = "VeryLazy",
        ft = "log",
    },

    -- Lots of small modules pulled into
    -- one git repository
    {
        "echasnovski/mini.nvim",
        event = "VeryLazy",
        config = function()
            require("mini.align").setup({})
            require("mini.cursorword").setup({})
        end,
    },

    -- Smoother Scrolling
    {
        "karb94/neoscroll.nvim",
        event = "VeryLazy",
        opts = {
            easing_function = "circular",
        },
    },

    -- Generate function/class/etc annotations
    {
        "danymat/neogen",
        cmd = {
            "Neogen",
        },
        dependencies = "nvim-treesitter/nvim-treesitter",
        opts = {
            snippet_engine = "luasnip",
            languages = {
                cs = {
                    template = {
                        annotation_convention = "xmldoc",
                    },
                },
            },
        },
    },

    -- Multiple cursor/multiple visual selection support
    {
        "mg979/vim-visual-multi",
        event = "VeryLazy",
        config = function()
            vim.cmd.VMTheme("codedark")
        end,
    },

    -- Maintain last cursor position in files
    {
        "ethanholz/nvim-lastplace",
        opts = {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit", "fugitive" },
            lastplace_open_folds = true,
        },
    },

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
        "rest-nvim/rest.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        ft = "http",
        opts = {
            skip_ssl_verification = true,
        },
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
        cmd = {
            "HopLineStart",
            "HopPattern",
            "HopWord",
            "HopAnywhere",
            "HopVertical",
        },
        opts = {
            keys = "etovxqpdygfblzhckisuran",
        },
    },

    -- Surround actions
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {},
    },

    -- Better list continuation
    {
        "gaoDean/autolist.nvim",
        ft = {
            "markdown",
            "text",
            "tex",
            "plaintex",
            "norg",
        },
        opts = {},
    },

    -- Tint inactive windows
    {
        "levouh/tint.nvim",
        event = "VeryLazy",
        opts = {
            highlight_ignore_patterns = {
                "WinSeparator",
            },
            window_ignore_function = function(winid)
                local bufid = vim.api.nvim_win_get_buf(winid)

                local ignoredFiletypes = { "DiffviewFiles", "DiffviewFileHistory", "neo-tree" }
                local ignoredBuftypes = { "terminal" }

                local isDiff = vim.api.nvim_win_get_option(winid, "diff")
                local isFloating = vim.api.nvim_win_get_config(winid).relative ~= ""
                local isIgnoredBuftype =
                    vim.tbl_contains(ignoredBuftypes, vim.api.nvim_buf_get_option(bufid, "buftype"))
                local isIgnoredFiletype =
                    vim.tbl_contains(ignoredFiletypes, vim.api.nvim_buf_get_option(bufid, "filetype"))

                return isDiff or isFloating or isIgnoredBuftype or isIgnoredFiletype
            end,
            tint = -30,
            saturation = 0.8,
        },
    },

    -- Highlight argument definitions and usages
    {
        "m-demare/hlargs.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {},
    },

    -- Vim Latex Support
    {
        "lervag/vimtex",
        ft = "tex",
        config = function()
            vim.g.vimtext_view_method = "zathura"
            vim.g.vimtex_view_general_viewer = "zathura"
        end,
    },

    {
        "akinsho/toggleterm.nvim",
        opts = {
            start_in_insert = false,
            direction = "float",
            autochdir = true,
            winbar = {
                enable = true,
                name_formatter = function(term) --  term: Terminal
                    return term.name
                end,
            },
        },
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
        "krivahtoo/silicon.nvim",
        build = "./install.sh build",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        cmd = {
            "Silicon",
        },
        opts = {
            font = "FiraCode Nerd Font=20",
            theme = "Monokai Extended",
            background = "#87F",
            pad_vert = 60,
            pad_horiz = 40,
            line_number = true,
            gobble = true,
            window_title = function()
                local devicons = require("nvim-web-devicons")
                local icon = devicons.get_icon_by_filetype(vim.bo.filetype)
                return icon .. " " .. vim.fn.fnamemodify(vim.fn.bufname(vim.fn.bufnr()), ":~:.")
            end,
        },
    },

    -- Nice sidebar cursor goodies
    {
        "gen740/SmoothCursor.nvim",
        event = "VeryLazy",
        opts = {
            priority = 8,
            fancy = {
                enable = true,
                head = { cursor = "⯈", texthl = "SmoothCursorCursor", linehl = nil },
                body = {
                    { cursor = "", texthl = "SmoothCursorTrailBig1" },
                    { cursor = "", texthl = "SmoothCursorTrailBig2" },
                    { cursor = "󰝥", texthl = "SmoothCursorTrailMedium" },
                    { cursor = "󰝥", texthl = "SmoothCursorTrailMedium" },
                    { cursor = "•", texthl = "SmoothCursorTrailSmall" },
                    { cursor = ".", texthl = "SmoothCursorTrailXSmall" },
                    { cursor = ".", texthl = "SmoothCursorTrailXSmall" },
                },
            },
            disabled_filetypes = { "NeogitNotification" },
        },
    },

    -- Color Picker
    {
        "uga-rosa/ccc.nvim",
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
        opts = {},
    },

    -- Better buffer deletion
    {
        "famiu/bufdelete.nvim",
        lazy = true,
    },

    -- Convert numbers between binary, decimal, & hex
    {
        "skosulor/nibbler",
        cmd = {
            "NibblerToBin",
            "NibblerToHex",
            "NibblerToDec",
            "NibblerToCArray",
            "NibblerHexStringToCArray",
            "NibblerToggle",
        },
        opts = {
            display_enabled = true,
        },
    },

    -- Preview Norm commands, global, macros
    {
        "smjonas/live-command.nvim",
        event = "VeryLazy",
        config = function()
            require("live-command").setup({
                commands = {
                    Norm = { cmd = "norm" },
                    Reg = {
                        cmd = "norm",
                        -- This will transform ":5Reg a" into ":norm 5@a"
                        args = function(opts)
                            return (opts.count == -1 and "" or opts.count) .. "@" .. opts.args
                        end,
                        range = "",
                    },
                },
            })
        end,
    },

    -- Better listing for diags, refs, quickfix, locs, etc.
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = {
            "Trouble",
            "TroubleClose",
            "TroubleToggle",
            "TroubleRefresh",
        },
        opts = {},
    },

    -- Github CLI integration
    {
        "ldelossa/gh.nvim",
        dependencies = { "ldelossa/litee.nvim" },
        config = function()
            require("litee.lib").setup()
            require("litee.gh").setup({
                refresh_interval = 60000,
            })
        end,
    },
}, {
    checker = {
        enabled = true,
        concurrency = 20,
    },
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
    dev = {
        path = "~/Git/Neovim",
    },
    checker = {
        notify = false,
    },
})
