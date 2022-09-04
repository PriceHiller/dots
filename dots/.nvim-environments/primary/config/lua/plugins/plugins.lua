local fn = vim.fn
local utils = require("utils.funcs")

-- Packer strap, install packer automatically and configure plugins
-- See the end of this file for how the variable `packer_strap` gets used
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_STRAP = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
    -- Update the runtime so packer can be used
    vim.o.runtimepath = vim.fn.stdpath("data") .. "/site/pack/*/start/*," .. vim.o.runtimepath
end

local packer = require("packer")

packer.init({
    max_jobs = 20,
})

return packer.startup({
    function(use)
        -- Performance boost on startup
        -- keep at top of plugins
        use({ "lewis6991/impatient.nvim" })

        -- Packer Itself
        use({ "wbthomason/packer.nvim" })

        -- Commonly used library
        use({
            "nvim-lua/plenary.nvim",
        })

        -- Nvim Notify
        use({
            "rcarriga/nvim-notify",
            config = function()
                require("plugins.configs.nvim-notify")
            end,
        })

        -- Color schemes
        use({ "folke/tokyonight.nvim" })
        use({
            "EdenEast/nightfox.nvim",
            config = function()
                require("nightfox").setup({
                    options = {
                        transparent = true,
                        dim_inactive = true,
                    },
                })
            end,
        })
        use({
            "rebelot/kanagawa.nvim",
            config = function()
                local colors = require("kanagawa.colors").setup({})
                vim.opt.fillchars:append({
                    horiz = "─",
                    horizup = "┴",
                    horizdown = "┬",
                    vert = "│",
                    vertleft = "┤",
                    vertright = "├",
                    verthoriz = "┼",
                })
                require("kanagawa").setup({
                    transparent = true,
                    dim_inactive = true,
                    globalStatus = true,
                    overrides = {
                        NeogitHunkHeader = { bg = colors.diff.text },
                        NeogitHunkHeaderHighlight = { fg = colors.git.changed, bg = colors.diff.text },
                        NeogitDiffContextHighlight = { bg = colors.diff.change },
                        NeogitDiffDeleteHighlight = { fg = colors.git.removed, bg = colors.diff.delete },
                        NeogitDiffAddHighlight = { fg = colors.git.added, bg = colors.diff.add },
                        NeogitCommitViewHeader = { fg = colors.git.changed, bg = colors.diff.text },
                        WinSeparator = { fg = "#54546D", bg = "NONE" },
                    },
                })
            end,
        })

        -- Icons for folders, files, etc.
        use({
            "kyazdani42/nvim-web-devicons",
            event = "BufEnter",
        })

        -- Tab Line at top of editor
        use({
            "akinsho/nvim-bufferline.lua",
            after = "nvim-web-devicons",
            requires = { "nvim-web-devicons" },
            config = function()
                require("plugins.configs.bufferline")
            end,
        })

        -- Statusline.
        use({
            "nvim-lualine/lualine.nvim",
            after = {
                "nvim-bufferline.lua",
                "tokyonight.nvim",
            },
            config = function()
                require("plugins.configs.statusline")
            end,
        })

        -- Indentation Guides
        use({
            "lukas-reineke/indent-blankline.nvim",
            event = "BufEnter",
            config = function()
                require("plugins.configs.indent-blankline")
            end,
        })

        -- Treesitter
        use({
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate",
            config = function()
                require("plugins.configs.treesitter")
            end,
        })

        use({
            "nvim-treesitter/nvim-treesitter-textobjects",
            after = "nvim-treesitter",
            config = function()
                require("nvim-treesitter.configs").setup({
                    textobjects = {
                        select = {
                            enable = true,
                            lookahead = true,
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
        })

        -- Better treesitter indentations
        -- NOTE: Remove this once treesitter gets up to par
        -- NOTE: this is just a placeholder until it is.
        use({
            "yioneko/nvim-yati",
            requires = "nvim-treesitter/nvim-treesitter",
        })

        -- Highlight given color codes
        use({
            "brenoprata10/nvim-highlight-colors",
            event = "BufEnter",
            config = function()
                require("nvim-highlight-colors").setup({
                    enable_tailwind = true,
                    render = "background",
                })
            end,
        })

        -- Dashboard when no file is given to nvim

        use({
            "goolord/alpha-nvim",
            requires = { "kyazdani42/nvim-web-devicons" },
            config = function()
                require("plugins.configs.alpha")
            end,
        })

        -- Telescope Extensions
        use({
            "nvim-telescope/telescope-fzf-native.nvim",
            run = "make",
        })

        use({
            "nvim-telescope/telescope-media-files.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
            "artart222/telescope_find_directories",
            "nvim-telescope/telescope-ui-select.nvim",
            { "nvim-telescope/telescope-smart-history.nvim", requires = "tami5/sqlite.lua" },
        })

        -- Telescope
        use({
            "nvim-telescope/telescope.nvim",
            config = function()
                require("plugins.configs.telescope-nvim")
            end,
        })

        -- File Tree
        use({
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v2.x",
            requires = {
                "kyazdani42/nvim-web-devicons",
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim",
            },
            config = function()
                require("plugins.configs.neotree")
            end,
        })

        -- Workspaces
        use({
            "natecraddock/workspaces.nvim",
            config = function()
                local workspaces = require("workspaces")
                workspaces.setup({
                    hooks = {
                        open = "Neotree",
                    },
                })
            end,
        })

        -- Lspconfig
        use({
            "neovim/nvim-lspconfig",
            requires = {
                "hrsh7th/cmp-nvim-lsp",
                "folke/lua-dev.nvim",
                "Decodetalkers/csharpls-extended-lsp.nvim",
                "williamboman/mason-lspconfig.nvim",
                "nanotee/sqls.nvim",
                "williamboman/mason.nvim",
                "simrat39/rust-tools.nvim",
                "Hoffs/omnisharp-extended-lsp.nvim",
            },
            config = function()
                require("mason").setup({})
                require("plugins.configs.lsp")
            end,
        })

        -- Incremental rename, easier to view renames
        use({
            "https://github.com/smjonas/inc-rename.nvim.git",
            config = function()
                require("inc_rename").setup({})
            end,
        })

        -- Show lsp diags at bottom
        use({
            "folke/trouble.nvim",
            config = function()
                require("trouble").setup()
            end,
            cmd = {
                "Trouble",
                "TroubleClose",
                "TroubleToggle",
                "TroubleRefresh",
            },
        })

        -- Better LSP Virtual Text Lines
        use({
            "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
            config = function()
                require("lsp_lines").setup()
            end,
        })

        -- Display LSP Progress
        use({
            "j-hui/fidget.nvim",
            config = function()
                require("plugins.configs.fidget-spinner")
            end,
        })

        -- Display Lsp Signature
        use({
            "ray-x/lsp_signature.nvim",
            config = function()
                require("lsp_signature").setup({
                    hint_prefix = "",
                    hint_enable = true,
                    floating_window = false,
                    toggle_key = "<M-x>",
                })
            end,
        })

        -- Code Action Menu, prettier ui for LSP code actions
        require("packer").use({
            "weilbith/nvim-code-action-menu",
        })

        -- Lsp From Null LS
        use({
            "jose-elias-alvarez/null-ls.nvim",
            config = function()
                require("plugins.configs.null_ls")
            end,
        })

        -- Autopairs
        use({
            "windwp/nvim-autopairs",
            config = function()
                require("nvim-autopairs").setup()
            end,
        })

        -- Snippets
        use({
            "rafamadriz/friendly-snippets",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
            requires = {
                "L3MON4D3/LuaSnip",
                "https://github.com/saadparwaiz1/cmp_luasnip",
            },
            after = "LuaSnip",
            event = "BufEnter",
        })

        -- Code completion
        use({
            "hrsh7th/nvim-cmp",
            requires = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/cmp-emoji",
                "hrsh7th/vim-vsnip",
                "hrsh7th/cmp-nvim-lsp-document-symbol",
                "hrsh7th/cmp-calc",
                "davidsierradz/cmp-conventionalcommits",
                "tamago324/cmp-zsh",
                "dmitmel/cmp-cmdline-history",
                "David-Kunz/cmp-npm",
                "lukas-reineke/cmp-rg",
            },
            config = function()
                require("plugins.configs._cmp")
            end,
        })

        use({
            "tzachar/cmp-fuzzy-buffer",
            requires = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
        })
        use({ "tzachar/cmp-fuzzy-path", requires = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" } })
        use({
            "saecki/crates.nvim",
            event = { "BufRead Cargo.toml" },
            requires = { { "nvim-lua/plenary.nvim" } },
            config = function()
                require("crates").setup()
            end,
        })

        -- DAP, debugger
        use({
            "mfussenegger/nvim-dap",
            config = function()
                require("dap.ext.vscode").load_launchjs()
                require("plugins.configs._dap")
            end,
            after = "nvim-notify",
        })

        -- Python debugger, dapinstall does not play nice with debugpy
        use({
            "mfussenegger/nvim-dap-python",
            after = "nvim-dap",
            config = function()
                require("plugins.configs.python-dap")
            end,
        })

        -- Virtual Text for DAP
        use({
            "theHamsta/nvim-dap-virtual-text",
            after = "nvim-dap",
            config = function()
                require("nvim-dap-virtual-text").setup({})
            end,
        })

        -- Fancy ui for dap
        use({
            "rcarriga/nvim-dap-ui",
            after = "nvim-dap",
            config = function()
                require("plugins.configs.dap-ui")
            end,
        })

        -- Code formatting
        use({
            "sbdchd/neoformat",
            cmd = "Neoformat",
            config = function()
                require("plugins.configs.neoformat")
            end,
        })

        use({
            "anuvyklack/pretty-fold.nvim",
            requires = "anuvyklack/nvim-keymap-amend",
            config = function()
                require("pretty-fold").setup({
                    fill_char = " ",
                })
            end,
        })

        -- Stabalize closing buffers
        use({
            "luukvbaal/stabilize.nvim",
            config = function()
                require("plugins.configs._stabilize")
            end,
        })

        -- Git signs
        use({
            "lewis6991/gitsigns.nvim",
            config = function()
                require("gitsigns").setup({
                    current_line_blame = true,
                    current_line_blame_opts = {
                        delay = 0,
                    },
                })
            end,
        })

        -- Highlight certain comments, TODO, BUG, etc.
        use({
            "B4mbus/todo-comments.nvim",
            event = "BufEnter",
            config = function()
                require("todo-comments").setup({})
            end,
        })

        -- Show possible key bindings during typing
        use({
            "folke/which-key.nvim",
            config = function()
                require("which-key").setup({})
            end,
        })

        -- Create full path if not existing on write
        use({
            "jghauser/mkdir.nvim",
            cmd = "new",
            config = function()
                require("mkdir")
            end,
        })

        -- Text commenting
        use({
            "terrortylor/nvim-comment",
            cmd = "CommentToggle",
            config = function()
                require("nvim_comment").setup()
            end,
        })

        -- Move selections with alt+movement key
        use({
            "matze/vim-move",
        })

        -- Register support in telescope with persistent save
        use({
            "AckslD/nvim-neoclip.lua",
            requires = {
                { "tami5/sqlite.lua", module = "sqlite" },
                { "nvim-telescope/telescope.nvim" },
            },
            config = function()
                require("plugins.configs._neoclip")
            end,
        })

        -- Markdown Previewer
        use({
            "iamcco/markdown-preview.nvim",
            run = "cd app && npm install",
            setup = function()
                vim.g.mkdp_filetypes = { "markdown" }
                vim.g.mkdp_browser = "firefox"
            end,
            ft = { "markdown" },
        })

        -- Better Git integration
        use({
            "TimUntersberger/neogit",
            config = function()
                require("neogit").setup({
                    disable_commit_confirmation = true,
                    integrations = {
                        diffview = true,
                    },
                })
            end,
            requires = {
                "sindrets/diffview.nvim",
            },
        })

        -- Ansible Syntax Highlighting
        use({
            "pearofducks/ansible-vim",
        })

        -- Better search display
        use({
            "kevinhwang91/nvim-hlslens",
            module = "hlslens",
            keys = "/",
        })

        -- Note Taking
        use({
            "nvim-neorg/neorg",
            config = function()
                require("plugins.configs._neorg")
            end,
            requires = {
                "nvim-lua/plenary.nvim",
                "nvim-neorg/neorg-telescope",
            },
            after = "nvim-treesitter",
        })

        -- Log Syntax Highlighting
        use({
            "MTDL9/vim-log-highlighting",
        })

        -- Lots of small modules pulled into
        -- one git repository
        use({
            "echasnovski/mini.nvim",
            config = function()
                -- Underline matching words to word undor cursor
                require("mini.cursorword").setup({})
                -- Surround operators
                -- require("mini.surround").setup({
                --     mappings = {
                --         add = "gs",
                --         delete = "ds",
                --         find = "",
                --         find_left = "",
                --         highlight = "",
                --         replace = "cs",
                --         update_n_lines = "",
                --     },
                -- })
            end,
        })

        -- Smoother Scrolling
        use({
            "karb94/neoscroll.nvim",
            config = function()
                require("neoscroll").setup({
                    easing_function = "circular",
                })
            end,
        })

        -- Generate function/class/etc annotations
        use({
            "danymat/neogen",
            requires = "nvim-treesitter/nvim-treesitter",
            config = function()
                require("neogen").setup({
                    snippet_engine = "luasnip",
                })
            end,
        })

        -- Center code, make it visually prettier
        use({
            "folke/zen-mode.nvim",
            config = function()
                require("zen-mode").setup({})
            end,
            cmd = "ZenMode",
        })

        -- Multiple cursor/multiple visual selection support
        use({
            "mg979/vim-visual-multi",
        })

        -- Editorconfig support
        use({
            "gpanders/editorconfig.nvim",
        })

        -- Maintain last cursor position in files
        use({
            "ethanholz/nvim-lastplace",
            config = function()
                require("nvim-lastplace").setup({
                    lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                    lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit", "fugitive" },
                    lastplace_open_folds = true,
                })
            end,
        })

        -- Diagnose startup time
        use({ "dstein64/vim-startuptime" })

        -- More codeactions
        use({
            "ThePrimeagen/refactoring.nvim",
            requires = {
                { "nvim-lua/plenary.nvim" },
                { "nvim-treesitter/nvim-treesitter" },
            },
        })

        -- Http Request Support
        use({
            "NTBBloodbath/rest.nvim",
            requires = {
                "https://github.com/nvim-lua/plenary.nvim",
            },
            config = function()
                local rest_nvim = require("rest-nvim")
                rest_nvim.setup({
                    -- This is a dev plugin, makes life easier
                    skip_ssl_verification = true,
                })
            end,
        })

        -- Mundo, browse and apply undo history
        use({
            "simnalamburt/vim-mundo",
        })

        -- Allows repeating actions and more
        use({
            "anuvyklack/hydra.nvim",
            requires = {
                "anuvyklack/keymap-layer.nvim",
                "lewis6991/gitsigns.nvim",
            },
            config = function()
                require("plugins.configs.hydra")
            end,
        })

        -- Faster motions
        use({
            "phaazon/hop.nvim",
            config = function()
                -- you can configure Hop the way you like here; see :h hop-config
                require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
            end,
        })

        -- Surround actions
        use({
            "kylechui/nvim-surround",
            config = function()
                require("nvim-surround").setup({})
            end,
        })

        -- Better list continuation
        use({
            "gaoDean/autolist.nvim",
            config = function()
                require("autolist").setup({})
            end,
        })

        -- Tint inactive windows
        use({
            "levouh/tint.nvim",
            config = function()
                require("tint").setup({
                    amt = -20,
                    saturation = 0.8,
                })
            end,
        })

        -- Leave at end!!!
        -- Install and deploy packer plugins
        -- automatically
        if PACKER_STRAP then
            vim.notify("Syncing packer from bootstrap")

            function _G.NotifyRestartNeeded()
                local notify_available, _ = require("notify")
                local message = "Neovim Restart Required to Finish Installation!"
                if notify_available then
                    vim.notify(message, vim.lsp.log_levels.WARN, {
                        title = "Packer Strap",
                        keep = function()
                            return true
                        end,
                    })
                else
                    vim.notify(message)
                end
            end

            vim.api.nvim_exec(
                [[
                autocmd User PackerCompileDone lua NotifyRestartNeeded()
                ]],
                false
            )
            require("packer").sync()
        end
    end,
    config = {
        compile_path = vim.fn.stdpath("config") .. "/lua/packer_compiled.lua",
    },
})
