return {
    {
        "rebelot/heirline.nvim",
        event = "ColorScheme",
        dependencies = {
            "lewis6991/gitsigns.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = function()
            local colors = require("kanagawa.colors").setup().palette

            local seps = {
                empty = { right = "", left = "" },
                full = { right = "", left = "" },
            }

            local utils = require("heirline.utils")
            local conditions = require("heirline.conditions")

            local pad = function(num)
                return string.rep(" ", num)
            end

            local margin = function(num)
                return {
                    provider = pad(num),
                }
            end

            -- NOTE: Vim Mode
            local VimMode = {
                init = function(self)
                    self.mode = vim.fn.mode(1)
                end,
                static = {
                    mode_names = { -- change the strings if you like it vvvvverbose!
                        n = "N",
                        no = "N?",
                        nov = "N?",
                        noV = "N?",
                        ["no\22"] = "N?",
                        niI = "Ni",
                        niR = "Nr",
                        niV = "Nv",
                        nt = "Nt",
                        v = "V",
                        vs = "Vs",
                        V = "V_",
                        Vs = "Vs",
                        ["\22"] = "^V",
                        ["\22s"] = "^V",
                        s = "S",
                        S = "S_",
                        ["\19"] = "^S",
                        i = "I",
                        ic = "Ic",
                        ix = "Ix",
                        R = "R",
                        Rc = "Rc",
                        Rx = "Rx",
                        Rv = "Rv",
                        Rvc = "Rv",
                        Rvx = "Rv",
                        c = "C",
                        cv = "Ex",
                        r = "...",
                        rm = "M",
                        ["r?"] = "?",
                        ["!"] = "!",
                        t = "T",
                    },
                    mode_colors = {
                        n = colors.crystalBlue,
                        i = colors.springGreen,
                        v = colors.lightBlue,
                        V = colors.lightBlue,
                        ["\22"] = colors.lightBlue,
                        c = colors.roninYellow,
                        s = colors.oniViolet,
                        S = colors.oniViolet,
                        ["\19"] = colors.oniViolet,
                        R = colors.carpYellow,
                        r = colors.carpYellow,
                        ["!"] = colors.peachRed,
                        t = colors.peachRed,
                    },
                    mode_color = function(self)
                        local mode = conditions.is_active() and vim.fn.mode() or "n"
                        return self.mode_colors[mode]
                    end,
                },
                {
                    {
                        provider = seps.full.left,
                        hl = function(self)
                            return {
                                fg = self:mode_color(),
                                bg = utils.get_highlight("StatusLine").bg,
                            }
                        end,
                    },
                    {
                        provider = function(self)
                            local padding = 1
                            return pad(padding) .. " " .. self.mode_names[self.mode] .. pad(padding)
                        end,
                        hl = function(self)
                            return { bg = self:mode_color(), bold = true, fg = colors.sumiInk0 }
                        end,
                    },
                    {
                        provider = seps.full.right,
                        hl = function(self)
                            return {
                                fg = self:mode_color(),
                                bg = utils.get_highlight("StatusLine").bg,
                            }
                        end,
                    },
                },

                update = {
                    "ModeChanged",
                    pattern = "*:*",
                    callback = vim.schedule_wrap(function()
                        vim.cmd.redrawstatus()
                    end),
                },
            }

            -- NOTE: File name and info
            local FileNameBlock = {
                -- let's first set up some attributes needed by this component and it's children
                init = function(self)
                    self.filename = vim.api.nvim_buf_get_name(0)
                end,
            }
            -- We can now define some children separately and add them later

            local FileIcon = {
                init = function(self)
                    local filename = self.filename
                    local extension = vim.fn.fnamemodify(filename, ":e")
                    self.icon, self.icon_color =
                        require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })

                    local overrides = {
                        ["rs"] = "",
                    }

                    local override = overrides[extension]
                    if override ~= nil then
                        self.icon = override
                    end
                end,
                provider = function(self)
                    return self.icon and (" " .. self.icon .. " ")
                end,
                hl = function(self)
                    return { fg = self.icon_color }
                end,
            }

            local FileName = {
                provider = function(self)
                    -- first, trim the pattern relative to the current directory. For other
                    -- options, see :h filename-modifers
                    local filename = vim.fn.fnamemodify(self.filename, ":.")
                    if filename == "" then
                        return "[No Name]"
                    end
                    -- now, if the filename would occupy more than 1/4th of the available
                    -- space, we trim the file path to its initials
                    -- See Flexible Components section below for dynamic truncation
                    if not conditions.width_percent_below(#filename, 0.25) then
                        filename = vim.fn.pathshorten(filename)
                    end
                    return filename
                end,
                hl = { fg = colors.sumiInk0 },
            }

            local FileFlags = {
                {
                    condition = function()
                        return vim.bo.modified
                    end,
                    provider = "  ",
                    hl = { fg = colors.sumiInk0 },
                },
                {
                    condition = function()
                        return not vim.bo.modifiable or vim.bo.readonly
                    end,
                    provider = " ",
                    hl = { fg = colors.sumiInk0 },
                },
            }

            -- Now, let's say that we want the filename color to change if the buffer is
            -- modified. Of course, we could do that directly using the FileName.hl field,
            -- but we'll see how easy it is to alter existing components using a "modifier"
            -- component
            local FileNameModifer = {
                hl = function()
                    if vim.bo.modified then
                        -- use `force` because we need to override the child's hl foreground
                        return { bold = true }
                    end
                end,
            }

            -- let's add the children to our FileNameBlock component
            FileNameBlock = utils.insert(FileNameBlock, {
                FileIcon,
                hl = function()
                    if conditions.is_active() then
                        return { bg = colors.sumiInk4 }
                    else
                        return { fg = colors.springViolet2, bg = colors.sumiInk0, force = true }
                    end
                end,
            }, {
                provider = seps.full.right .. " ",
                hl = function()
                    if conditions.is_active() then
                        return { fg = colors.sumiInk4, bg = colors.carpYellow }
                    else
                        return { fg = colors.sumiInk0, bg = colors.sumiInk3 }
                    end
                end,
            }, {
                hl = function()
                    if conditions.is_active() then
                        return { fg = colors.carpYellow, bg = colors.carpYellow }
                    else
                        return { fg = colors.oniViolet2, bg = colors.sumiInk3, force = true }
                    end
                end,
                utils.insert(FileNameModifer, FileName),
                FileFlags,
            }, { provider = "%<" }, {
                provider = seps.full.right,
                hl = function()
                    if conditions.is_active() then
                        return { fg = colors.carpYellow, bg = utils.get_highlight("StatusLine").bg }
                    else
                        return { fg = colors.sumiInk3, bg = utils.get_highlight("StatusLineNC").bg }
                    end
                end,
            })

            local buffer_hl = {
                active = {
                    fg = colors.fujiWhite,
                    bg = colors.sumiInk4,
                },
                inactive = {
                    fg = colors.fujiGray,
                    bg = colors.sumiInk3,
                },
            }
            local StatusLineBufnr = {
                provider = function(self)
                    return tostring(self.bufnr) .. ". "
                end,
                hl = "Comment",
            }

            -- we redefine the filename component, as we probably only want the tail and not the relative path
            local StatusLineFileName = {
                init = function(self)
                    self.lfilename = vim.fn.fnamemodify(self.filename, ":~:.")
                    if self.lfilename == "" then
                        self.lfilename = "[No Name]"
                    end
                end,
                flexible = 2,
                {
                    provider = function(self)
                        return self.lfilename
                    end,
                },
                {
                    provider = function(self)
                        return vim.fn.pathshorten(self.lfilename)
                    end,
                },
                hl = function(self)
                    local fg
                    if self.is_active then
                        fg = buffer_hl.active.fg
                    else
                        fg = buffer_hl.inactive.fg
                    end
                    return { bold = self.is_active or self.is_visible, italic = true, fg = fg }
                end,
            }

            -- this looks exactly like the FileFlags component that we saw in
            -- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
            -- also, we are adding a nice icon for terminal buffers.
            local StatusLineFileFlags = {
                {
                    condition = function(self)
                        return vim.api.nvim_buf_get_option(self.bufnr, "modified")
                    end,
                    provider = "  ",
                    hl = { fg = colors.springGreen },
                },
                {
                    condition = function(self)
                        return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
                            or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
                    end,
                    provider = function(self)
                        if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
                            return "  "
                        else
                            return " "
                        end
                    end,
                    hl = { fg = colors.roninYellow },
                },
            }

            -- Here the filename block finally comes together
            local StatusLineFileNameBlock = {
                init = function(self)
                    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
                end,
                hl = function(self)
                    if self.is_active then
                        return buffer_hl.active
                    else
                        return buffer_hl.inactive
                    end
                end,
                on_click = {
                    callback = function(_, minwid, _, button)
                        if button == "m" then -- close on mouse middle click
                            vim.schedule(function()
                                vim.api.nvim_buf_delete(minwid, { force = false })
                            end)
                        else
                            vim.api.nvim_win_set_buf(0, minwid)
                        end
                    end,
                    minwid = function(self)
                        return self.bufnr
                    end,
                    name = "heirline_tabline_buffer_callback",
                },
                StatusLineBufnr,
                FileIcon, -- turns out the version defined in #crash-course-part-ii-filename-and-friends can be reutilized as is here!
                StatusLineFileName,
                StatusLineFileFlags,
            }

            -- a nice "x" button to close the buffer
            local StatusLineCloseButton = {
                condition = function(self)
                    return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
                end,
                {
                    provider = " 󰅙 ",
                    hl = function(self)
                        local bg
                        if self.is_active then
                            bg = buffer_hl.active.bg
                        else
                            bg = buffer_hl.inactive.bg
                        end
                        return { fg = colors.waveRed, bg = bg }
                    end,
                    on_click = {
                        callback = function(_, minwid)
                            vim.schedule(function()
                                vim.api.nvim_buf_delete(minwid, { force = false })
                                vim.cmd.redrawtabline()
                            end)
                        end,
                        minwid = function(self)
                            return self.bufnr
                        end,
                        name = "heirline_tabline_close_buffer_callback",
                    },
                },
            }

            -- The final touch!
            local StatusLineBufferBlock = {
                {
                    provider = seps.full.left,
                    hl = function(self)
                        local fg
                        if self.is_active then
                            fg = buffer_hl.active.bg
                        else
                            fg = buffer_hl.inactive.bg
                        end
                        return { fg = fg, bg = utils.get_highlight("StatusLine").bg }
                    end,
                },
                StatusLineFileNameBlock,
                StatusLineCloseButton,
                {
                    provider = seps.full.right,
                    hl = function(self)
                        local fg
                        if self.is_active then
                            fg = buffer_hl.active.bg
                        else
                            fg = buffer_hl.inactive.bg
                        end
                        return { fg = fg, bg = utils.get_highlight("StatusLine").bg }
                    end,
                },
            }

            -- and here we go
            local BufferLine = utils.make_buflist(
                StatusLineBufferBlock,
                { provider = "", hl = { fg = colors.katanaGray } }, -- left truncation, optional (defaults to "<")
                { provider = "", hl = { fg = colors.katanaGray } } -- right trunctation, also optional (defaults to ...... yep, ">")
                -- by the way, open a lot of buffers and try clicking them ;)
            )

            local Tabpage = {
                static = {
                    num_mappings = {},
                },
                provider = function(self)
                    local prefix = ""
                    if self.is_active then
                        prefix = ""
                    end

                    local sep = ""

                    if #vim.api.nvim_list_tabpages() ~= self.tabnr then
                        sep = "।"
                    end
                    return prefix .. "%" .. self.tabnr .. "T " .. self.tabpage .. " %T" .. sep
                end,
                hl = function(self)
                    if self.is_active then
                        return { fg = colors.sumiInk0, bg = colors.sakuraPink }
                    else
                        return { fg = colors.sumiInk0, bg = colors.sakuraPink }
                    end
                end,
            }

            local TabPages = {
                -- only show this component if there's 2 or more tabpages
                condition = function()
                    return #vim.api.nvim_list_tabpages() >= 2
                end,
                margin(1),
                {
                    provider = seps.full.left,
                    hl = { fg = colors.sakuraPink, bg = utils.get_highlight("StatusLine").bg },
                },
                utils.make_tablist(Tabpage),
                {
                    provider = seps.full.left,
                    hl = { fg = colors.peachRed, bg = colors.sakuraPink },
                },
                {
                    provider = "%999X 󰀘 %X",
                    hl = function()
                        return {
                            fg = colors.sumiInk0,
                            bg = colors.peachRed,
                        }
                    end,
                },
                {
                    provider = seps.full.right,
                    hl = { fg = colors.peachRed, bg = utils.get_highlight("StatusLine").bg },
                },
            }

            local InactiveWinbar = {
                condition = conditions.is_not_active,
                {
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk0, bg = utils.get_highlight("WinBarNC").bg }
                        end,
                    },
                    FileNameBlock,
                },
            }
            local ActiveWinbar = {
                condition = conditions.is_active,
                {
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk4, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    FileNameBlock,
                    margin(1),
                    {
                        condition = conditions.lsp_attached,
                        {
                            {
                                provider = seps.full.left,
                                hl = { fg = colors.oniViolet, bg = utils.get_highlight("WinBarNC").bg },
                            },
                            {
                                provider = " ",
                                hl = {
                                    bg = colors.oniViolet,
                                    fg = colors.sumiInk0,
                                },
                            },
                            {
                                provider = seps.full.right,
                                hl = { fg = colors.oniViolet, bg = colors.oniViolet2 },
                            },
                        },
                        {
                            update = { "LspAttach", "LspDetach" },

                            provider = function()
                                local names = {}
                                for _, server in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                                    table.insert(names, server.name)
                                end
                                return " " .. table.concat(names, ", ")
                            end,
                            hl = { fg = colors.sumiInk0, bg = colors.oniViolet2 },
                        },
                        {
                            provider = seps.full.right,
                            hl = function()
                                local bg = utils.get_highlight("WinBar").bg
                                if conditions.has_diagnostics() then
                                    bg = colors.sumiInk2
                                end
                                return { fg = colors.oniViolet2, bg = bg }
                            end,
                        },
                    },
                    {
                        condition = conditions.has_diagnostics,
                        static = {
                            error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
                            warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
                            info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
                            hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
                        },
                        init = function(self)
                            self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                            self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                            self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
                            self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
                        end,
                        update = { "DiagnosticChanged", "BufEnter" },
                        {
                            provider = " ",
                            hl = { fg = colors.sumiInk2, bg = colors.sumiInk2 },
                        },
                        {
                            provider = function(self)
                                -- 0 is just another output, we can decide to print it or not!
                                return self.errors > 0 and (self.error_icon .. self.errors .. " ")
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticError").fg, bg = colors.sumiInk2 },
                        },
                        {
                            provider = function(self)
                                return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticWarn").fg, bg = colors.sumiInk2 },
                        },
                        {
                            provider = function(self)
                                return self.info > 0 and (self.info_icon .. self.info .. " ")
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticInfo").fg, bg = colors.sumiInk2 },
                        },
                        {
                            provider = function(self)
                                return self.hints > 0 and (self.hint_icon .. self.hints)
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticHint").fg, bg = colors.sumiInk2 },
                        },
                        {
                            provider = seps.full.right,
                            hl = { fg = colors.sumiInk2, bg = utils.get_highlight("WinBar").bg },
                        },
                    },
                },
                {
                    provider = "%=",
                },
                {
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk5, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        provider = "%p%% ",
                        hl = {
                            fg = colors.fujiWhite,
                            bg = colors.sumiInk5,
                        },
                    },
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.carpYellow, bg = colors.sumiInk5 }
                        end,
                    },
                    {
                        provider = "  ",
                        hl = {
                            fg = colors.sumiInk0,
                            bg = colors.carpYellow,
                        },
                    },
                    {
                        provider = seps.full.right,
                        hl = function()
                            return { fg = colors.carpYellow, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                },
                margin(1),
                {
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk5, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        provider = "%3l:%c ",
                        hl = {
                            fg = colors.fujiWhite,
                            bg = colors.sumiInk5,
                        },
                    },
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.crystalBlue, bg = colors.sumiInk5 }
                        end,
                    },
                    {
                        provider = "  ",
                        hl = {
                            fg = colors.sumiInk0,
                            bg = colors.crystalBlue,
                        },
                    },
                    {
                        provider = seps.full.right,
                        hl = function()
                            return { fg = colors.crystalBlue, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                },
            }

            vim.opt.showcmdloc = "statusline"

            return {
                statusline = {
                    {
                        hl = "StatusLine",
                        fallthrough = false,
                    },
                    VimMode,
                    {
                        condition = function()
                            return vim.v.hlsearch ~= 0
                        end,
                        {
                            provider = " " .. seps.full.left,
                            hl = {
                                fg = colors.surimiOrange,
                                bg = utils.get_highlight("StatusLine").bg,
                            },
                        },
                        {
                            provider = "  ",
                            hl = {
                                fg = colors.sumiInk0,
                                bg = colors.surimiOrange,
                                bold = true,
                            },
                        },
                        {
                            provider = seps.full.right,
                            hl = {
                                fg = colors.surimiOrange,
                                bg = colors.sumiInk4,
                            },
                        },
                        {
                            init = function(self)
                                local ok, search = pcall(vim.fn.searchcount)
                                if ok and search.total then
                                    self.search = search
                                end
                            end,
                            provider = function(self)
                                local search = self.search
                                return string.format(" %d/%d", search.current, math.min(search.total, search.maxcount))
                            end,
                            hl = {
                                fg = colors.fujiWhite,
                                bg = colors.sumiInk4,
                            },
                        },
                        {
                            provider = seps.full.right,
                            hl = {
                                fg = colors.sumiInk4,
                                bg = utils.get_highlight("StatusLine").bg,
                            },
                        },
                    },
                    {
                        condition = function()
                            return vim.fn.reg_recording() ~= ""
                        end,
                        update = {
                            "RecordingEnter",
                            "RecordingLeave",
                        },
                        {
                            provider = " " .. seps.full.left,
                            hl = {
                                fg = colors.surimiOrange,
                                bg = utils.get_highlight("StatusLine").bg,
                            },
                        },
                        {
                            provider = " 󰻂 ",
                            hl = {
                                fg = colors.sumiInk0,
                                bg = colors.surimiOrange,
                                bold = true,
                            },
                        },
                        {
                            provider = seps.full.right,
                            hl = {
                                fg = colors.surimiOrange,
                                bg = colors.sumiInk4,
                            },
                        },
                        {
                            {
                                provider = " [",
                                hl = {
                                    fg = colors.peachRed,
                                },
                            },
                            {
                                provider = function()
                                    return vim.fn.reg_recording()
                                end,
                                hl = {
                                    fg = colors.surimiOrange,
                                    bg = colors.sumiInk4,
                                    bold = true,
                                },
                            },
                            {
                                provider = "]",
                                hl = {
                                    fg = colors.peachRed,
                                },
                            },
                        },
                        {
                            provider = seps.full.right,
                            hl = {
                                fg = colors.sumiInk4,
                                bg = utils.get_highlight("StatusLine").bg,
                            },
                        },
                    },
                    margin(1),
                    {
                        {
                            provider = seps.full.left,
                            hl = function()
                                if conditions.is_active() then
                                    return { fg = colors.sumiInk4, bg = utils.get_highlight("StatusLine").bg }
                                else
                                    return { fg = colors.sumiInk0, bg = utils.get_highlight("StatusLineNC").bg }
                                end
                            end,
                        },
                        FileNameBlock,
                    },
                    margin(1),
                    {
                        condition = conditions.is_git_repo,

                        init = function(self)
                            self.status_dict = vim.b.gitsigns_status_dict
                            self.has_changes = self.status_dict.added ~= 0
                                or self.status_dict.removed ~= 0
                                or self.status_dict.changed ~= 0
                        end,

                        {
                            provider = seps.full.left,
                            hl = {
                                fg = colors.springGreen,
                                bg = utils.get_highlight("StatusLine").bg,
                            },
                        },
                        {
                            provider = "  ",
                            hl = {
                                fg = colors.sumiInk0,
                                bg = colors.springGreen,
                            },
                        },
                        {
                            provider = seps.full.right,
                            hl = {
                                fg = colors.springGreen,
                                bg = colors.autumnGreen,
                            },
                        },
                        {
                            provider = function(self)
                                local branch = self.status_dict.head
                                return " " .. self.status_dict.head
                            end,
                            hl = { fg = colors.sumiInk0, bg = colors.autumnGreen },
                        },
                        {
                            provider = function(self)
                                local suffix = ""
                                if self.has_changes then
                                    suffix = " "
                                end
                                return seps.full.right .. suffix
                            end,
                            hl = function(self)
                                local bg = utils.get_highlight("StatusLine").bg
                                if self.has_changes then
                                    bg = colors.sumiInk4
                                end
                                return {
                                    fg = colors.autumnGreen,
                                    bg = bg,
                                }
                            end,
                        },
                        {
                            provider = function(self)
                                local count = self.status_dict.added or 0
                                return count > 0 and (" " .. count)
                            end,
                            hl = { fg = utils.get_highlight("DiffAdd").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                local count = self.status_dict.changed or 0
                                return count > 0 and ("  " .. count)
                            end,
                            hl = { fg = utils.get_highlight("DiffChanged").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                local count = self.status_dict.removed or 0
                                return count > 0 and ("  " .. count)
                            end,
                            hl = { fg = utils.get_highlight("DiffDelete").fg, bg = colors.sumiInk4 },
                        },
                        {
                            condition = function(self)
                                return self.has_changes
                            end,
                            provider = seps.full.right,
                            hl = {
                                fg = colors.sumiInk4,
                                bg = utils.get_highlight("StatusLine").bg,
                            },
                        },
                    },
                    -- Align Right
                    {
                        provider = "%=",
                    },
                    BufferLine,
                    {
                        provider = seps.full.left,
                        hl = { fg = colors.roninYellow, bg = utils.get_highlight("StatusLine").bg },
                    },
                    {
                        provider = " 󱧶 ",
                        hl = { fg = colors.sumiInk0, bg = colors.roninYellow },
                    },
                    {
                        provider = seps.full.right,
                        hl = { fg = colors.roninYellow, bg = utils.get_highlight("StatusLine").bg },
                    },
                    TabPages,
                },
                winbar = {
                    InactiveWinbar,
                    ActiveWinbar,
                },
                opts = {
                    disable_winbar_cb = function(args)
                        return conditions.buffer_matches({
                            buftype = { "nofile", "prompt", "quickfix", "terminal" },
                            filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
                        }, args.buf)
                    end,
                },
            }
        end,
    },
}
