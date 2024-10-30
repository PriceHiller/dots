return {
    {
        "rebelot/heirline.nvim",
        lazy = false,
        dependencies = {
            "lewis6991/gitsigns.nvim",
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
                    self.mode = vim.api.nvim_get_mode().mode
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
                        local mode = conditions.is_active() and vim.api.nvim_get_mode().mode or "n"
                        return self.mode_colors[mode] or colors.crystalBlue
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
                            return pad(padding)
                                .. " "
                                .. (self.mode_names[self.mode] or (" " .. vim.inspect(self.mode)))
                                .. pad(padding)
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
                    local buftype = vim.api.nvim_get_option_value("buftype", {
                        buf = self.bufnr,
                    })

                    local filetype = vim.api.nvim_get_option_value("filetype", {
                        buf = self.bufnr,
                    })
                    self.icon, self.icon_color =
                        require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })

                    local ft_overrides = {
                        ["rust"] = { icon = "", icon_color = self.icon_color },
                        ["sshconfig"] = { icon = "󰴳", icon_color = colors.carpYellow },
                        ["sshdconfig"] = "sshconfig",
                        ["help"] = { icon = "󰋗", icon_color = colors.springGreen },
                        ["octo"] = { icon = "", icon_color = colors.fujiWhite },
                    }

                    local buftype_overrides = {
                        ["terminal"] = { icon = " ", icon_color = colors.roninYellow },
                    }

                    local function get_override(name, overrides)
                        local override = overrides[name]
                        if type(override) == "string" then
                            override = get_override(override, overrides)
                        end
                        return override
                    end

                    local ft_override = get_override(filetype, ft_overrides)
                    if ft_override ~= nil then
                        self.icon = ft_override.icon
                        self.icon_color = ft_override.icon_color
                    end

                    local buftype_override = get_override(buftype, buftype_overrides)
                    if buftype_override ~= nil then
                        self.icon = buftype_override.icon
                        self.icon_color = buftype_override.icon_color
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
                    local filename = ""
                    local buftype = vim.api.nvim_get_option_value("buftype", {
                        buf = self.bufnr,
                    })
                    if buftype == "terminal" then
                        local subs = 0
                        filename, subs = self.filename:gsub(".*;", "")
                        if subs == 0 then
                            filename = self.filename:gsub(".*:", "")
                        end
                    else
                        ---@diagnostic disable-next-line: cast-local-type
                        filename = vim.fn.fnamemodify(self.filename, ":~:.")
                        if not conditions.width_percent_below(#filename, 0.5, true) then
                            filename = vim.fn.pathshorten(filename)
                        end
                    end
                    if filename == "" then
                        filename = "[No Name]"
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
                    provider = "  ",
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
                hl = function(self)
                    local bg = self.bg_color_right
                    if conditions.is_active() then
                        return { fg = colors.carpYellow, bg = bg }
                    else
                        return { fg = colors.sumiInk3, bg = bg }
                    end
                end,
            })

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
                        sep = "|"
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

            local cur_bufs = function()
                return vim.iter(vim.api.nvim_list_bufs())
                    :filter(function(buf)
                        return vim.fn.buflisted(buf) == 1
                    end)
                    :filter(vim.api.nvim_buf_is_loaded)
                    :filter(vim.api.nvim_buf_is_valid)
                    :totable()
            end

            local Buffers = {
                update = { "BufEnter", "BufNew", "VimEnter", "BufWipeout", "BufUnload", "BufDelete" },
                condition = function()
                    return #cur_bufs() > 0
                end,
                {
                    provider = seps.full.left,
                    hl = { fg = colors.carpYellow, bg = utils.get_highlight("StatusLine").bg },
                },
                {
                    provider = function()
                        return vim.api.nvim_get_current_buf()
                    end,
                    hl = { fg = colors.sumiInk0, bg = colors.carpYellow },
                },
                {
                    provider = " " .. seps.full.left,
                    hl = { fg = colors.roninYellow, bg = colors.carpYellow },
                },
                {
                    provider = function()
                        return ("%d  "):format(#cur_bufs())
                    end,
                    hl = function()
                        return {
                            fg = colors.sumiInk0,
                            bg = colors.roninYellow,
                        }
                    end,
                },
                {
                    provider = seps.full.right,
                    hl = { fg = colors.roninYellow, bg = utils.get_highlight("StatusLine").bg },
                },
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
                init = function(self)
                    self.bufnr = vim.api.nvim_get_current_buf()
                end,
                condition = conditions.is_active,
                {
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk4, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        FileNameBlock,
                        static = {
                            bg_color_right = nil,
                        },
                    },
                    margin(1),
                    {
                        {
                            condition = function()
                                return conditions.lsp_attached() or conditions.has_diagnostics()
                            end,
                            {
                                provider = seps.full.left,
                                hl = { fg = colors.oniViolet, bg = utils.get_highlight("WinBarNC").bg },
                            },
                            {
                                provider = function(self)
                                    return " "
                                        .. (
                                            (not vim.diagnostic.is_enabled({ bufnr = self.bufnr })) and "󱃓 "
                                            or "󰪥 "
                                        )
                                end,
                                hl = {
                                    bg = colors.oniViolet,
                                    fg = colors.sumiInk0,
                                },
                            },
                            {
                                provider = seps.full.right,
                                hl = function()
                                    local bg = colors.oniViolet2
                                    if conditions.has_diagnostics() and not conditions.lsp_attached() then
                                        bg = colors.sumiInk2
                                    end

                                    return { fg = colors.oniViolet, bg = bg }
                                end,
                            },
                            {
                                condition = conditions.lsp_attached,
                                update = { "LspAttach", "LspDetach" },
                                {
                                    provider = function()
                                        local names = {}
                                        for _, server in
                                            ipairs(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }))
                                        do
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
                                            bg = colors.sumiInk4
                                        end
                                        return { fg = colors.oniViolet2, bg = bg }
                                    end,
                                },
                            },
                        },
                    },
                    {
                        condition = conditions.has_diagnostics,
                        static = {
                            error_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.ERROR] .. " ",
                            warn_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.WARN] .. " ",
                            info_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.INFO] .. " ",
                            hint_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.HINT] .. " ",
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
                            hl = { fg = colors.sumiInk4, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                -- 0 is just another output, we can decide to print it or not!
                                return self.errors > 0 and (self.error_icon .. self.errors .. " ")
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticError").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticWarn").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                return self.info > 0 and (self.info_icon .. self.info .. " ")
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticInfo").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                return self.hints > 0 and (self.hint_icon .. self.hints)
                            end,
                            hl = { fg = utils.get_highlight("DiagnosticHint").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = seps.full.right,
                            hl = function()
                                return {
                                    fg = colors.sumiInk4,
                                    bg = utils.get_highlight("WinBar").bg,
                                }
                            end,
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
                            return { fg = colors.sumiInk4, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        provider = function()
                            return "spell "
                        end,
                        hl = {
                            fg = colors.fujiWhite,
                            bg = colors.sumiInk4,
                        },
                    },
                    {
                        {
                            provider = seps.full.left,
                            hl = function()
                                return {
                                    fg = vim.opt_local.spell:get() and colors.springGreen or colors.peachRed,
                                    bg = colors.sumiInk4,
                                }
                            end,
                        },
                        {
                            provider = function()
                                return vim.opt_local.spell:get() and " " or " "
                            end,
                            hl = function()
                                return {
                                    fg = colors.sumiInk0,
                                    bg = vim.opt_local.spell:get() and colors.springGreen or colors.peachRed,
                                }
                            end,
                        },
                        {
                            provider = seps.full.right .. " ",
                            hl = function()
                                return {
                                    fg = vim.opt_local.spell:get() and colors.springGreen or colors.peachRed,
                                    bg = utils.get_highlight("WinBar").bg,
                                }
                            end,
                        },
                    },
                },
                {
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk4, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        provider = function()
                            return "wrap "
                        end,
                        hl = {
                            fg = colors.fujiWhite,
                            bg = colors.sumiInk4,
                        },
                    },
                    {
                        {
                            provider = seps.full.left,
                            hl = function()
                                return {
                                    fg = vim.opt_local.wrap:get() and colors.springGreen or colors.peachRed,
                                    bg = colors.sumiInk4,
                                }
                            end,
                        },
                        {
                            provider = function()
                                return vim.opt_local.wrap:get() and " " or " "
                            end,
                            hl = function()
                                return {
                                    fg = colors.sumiInk0,
                                    bg = vim.opt_local.wrap:get() and colors.springGreen or colors.peachRed,
                                }
                            end,
                        },
                        {
                            provider = seps.full.right .. " ",
                            hl = function()
                                return {
                                    fg = vim.opt_local.wrap:get() and colors.springGreen or colors.peachRed,
                                    bg = utils.get_highlight("WinBar").bg,
                                }
                            end,
                        },
                    },
                },
                {
                    update = {
                        "BufAdd",
                        "BufEnter",
                        "FileType",
                    },
                    init = function(self)
                        self.filename = vim.api.nvim_buf_get_name(0)
                    end,
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.crystalBlue, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        provider = function()
                            local ft = vim.bo.filetype
                            if ft == nil or ft == "" then
                                ft = "[No Filetype]"
                            end
                            return ft .. " "
                        end,
                        hl = {
                            fg = colors.sumiInk0,
                            bg = colors.crystalBlue,
                        },
                    },
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk4, bg = colors.crystalBlue }
                        end,
                    },
                    {
                        FileIcon,
                        hl = { bg = colors.sumiInk4 },
                    },
                    {
                        provider = seps.full.right,
                        hl = function()
                            return { fg = colors.sumiInk4, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                },
                margin(1),
                {
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk4, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        provider = function()
                            ---@diagnostic disable-next-line: undefined-field
                            return (vim.b.ufo_foldlevel or vim.opt_local.foldlevel:get()) .. " "
                        end,
                        hl = {
                            fg = colors.fujiWhite,
                            bg = colors.sumiInk4,
                        },
                    },
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.surimiOrange, bg = colors.sumiInk4 }
                        end,
                    },
                    {
                        provider = "  ",
                        hl = {
                            fg = colors.sumiInk0,
                            bg = colors.surimiOrange,
                        },
                    },
                    {
                        provider = seps.full.right,
                        hl = function()
                            return { fg = colors.surimiOrange, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                },
                margin(1),
                {
                    update = "CursorMoved",
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.sumiInk4, bg = utils.get_highlight("WinBar").bg }
                        end,
                    },
                    {
                        provider = "%l:%c ",
                        hl = {
                            fg = colors.fujiWhite,
                            bg = colors.sumiInk4,
                        },
                    },
                    {
                        provider = seps.full.left,
                        hl = function()
                            return { fg = colors.crystalBlue, bg = colors.sumiInk4 }
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
            local timer = vim.uv.new_timer()
            timer:start(
                1000,
                500,
                vim.schedule_wrap(function()
                    vim.api.nvim_exec_autocmds("User", { pattern = "HeirlineOrgUpdate" })
                end)
            )

            local org = require("orgmode")
            local OrgDate = require("orgmode.objects.date")
            local Orgmode = {
                condition = function()
                    return org.initialized
                end,
                update = {
                    "User",
                    pattern = "HeirlineOrgUpdate",
                },
                margin(1),
                {
                    provider = seps.full.left,
                    hl = {
                        fg = colors.sakuraPink,
                        bg = utils.get_highlight("StatusLine").bg,
                    },
                },
                {
                    provider = "  ",
                    hl = {
                        fg = colors.sumiInk0,
                        bg = colors.sakuraPink,
                    },
                },
                {
                    provider = seps.full.right .. " ",
                    hl = {
                        fg = colors.sakuraPink,
                        bg = colors.sumiInk4,
                    },
                },
                {
                    hl = {
                        fg = colors.sakuraPink,
                        bg = colors.sumiInk4,
                    },
                    provider = function()
                        local clocked_in_task = function()
                            local headline = org.clock.clocked_headline
                            if not headline then
                                return
                            end

                            local clocked_time = headline:get_logbook():get_total_with_active():to_string()
                            local effort = headline:get_property("effort")
                            local time_elapsed = ""
                            if effort then
                                time_elapsed = ("[%s/%s]"):format(clocked_time, effort)
                            else
                                time_elapsed = ("[%s]"):format(clocked_time)
                            end

                            -- Get the title and remove some org syntax from it
                            local title = headline:get_title():gsub("[~/*_=+]", "")

                            local message = ("%s %s"):format(time_elapsed, title)
                            if #message > 60 then
                                message = message:sub(1, 65) .. "…"
                            end
                            return message
                        end
                        local remaining_tasks_today = function()
                            local remaining_tasks_today = 0
                            local today = OrgDate:today()
                            for _, orgfile in pairs(org.files.files) do
                                ---@type OrgFile
                                orgfile = orgfile
                                for _, headline in ipairs(orgfile:get_opened_unfinished_headlines()) do
                                    for _, date in ipairs(headline:get_deadline_and_scheduled_dates()) do
                                        if date:is_same_or_before(today, "day") then
                                            remaining_tasks_today = remaining_tasks_today + 1
                                            break
                                        end
                                    end
                                end
                            end
                            return ("Tasks Remaining: %d"):format(remaining_tasks_today)
                        end
                        return clocked_in_task() or remaining_tasks_today()
                    end,
                },
                {
                    provider = seps.full.right .. " ",
                    hl = {
                        fg = colors.sumiInk4,
                        bg = utils.get_highlight("StatusLine").bg,
                    },
                },
            }

            return {
                statusline = {
                    {
                        hl = "StatusLine",
                        fallthrough = false,
                    },
                    VimMode,
                    {
                        condition = function()
                            return vim.v.hlsearch > 0
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
                                if search == nil then
                                    return " ?/?"
                                else
                                    return string.format(
                                        " %d/%d",
                                        search.current,
                                        math.min(search.total, search.maxcount)
                                    )
                                end
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
                            local _, reg_recording = pcall(vim.fn.reg_recording)
                            return reg_recording ~= ""
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
                                    bg = colors.sumiInk4,
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
                                    bg = colors.sumiInk4,
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
                            {
                                provider = seps.full.left,
                                hl = {
                                    fg = colors.lightBlue,
                                    bg = utils.get_highlight("StatusLine").bg,
                                },
                            },
                            {
                                provider = "  ",
                                hl = {
                                    fg = colors.sumiInk0,
                                    bg = colors.lightBlue,
                                },
                            },
                            {
                                provider = seps.full.right,
                                hl = {
                                    fg = colors.lightBlue,
                                    bg = colors.waveAqua2,
                                },
                            },
                            {
                                provider = function()
                                    local cwd = vim.uv.cwd() or ""
                                    cwd = vim.fn.fnamemodify(cwd, ":~")
                                    if not conditions.width_percent_below(#cwd, 0.3, false) then
                                        cwd = vim.fn.pathshorten(cwd)
                                    end
                                    return " " .. cwd
                                end,
                                hl = {
                                    fg = colors.sumiInk0,
                                    bg = colors.waveAqua2,
                                },
                            },
                            {
                                provider = seps.full.right,
                                hl = {
                                    fg = colors.waveAqua2,
                                    bg = utils.get_highlight("StatusLine").bg,
                                },
                            },
                        },
                    },
                    {
                        condition = conditions.is_git_repo,

                        init = function(self)
                            self.status_dict = vim.b.gitsigns_status_dict
                            self.has_changes = self.status_dict.added ~= 0
                                or self.status_dict.removed ~= 0
                                or self.status_dict.changed ~= 0
                        end,
                        margin(1),
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
                            hl = { fg = utils.get_highlight("@diff.plus").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                local count = self.status_dict.changed or 0
                                return count > 0 and ("  " .. count)
                            end,
                            hl = { fg = utils.get_highlight("@diff.delta").fg, bg = colors.sumiInk4 },
                        },
                        {
                            provider = function(self)
                                local count = self.status_dict.removed or 0
                                return count > 0 and ("  " .. count)
                            end,
                            hl = { fg = utils.get_highlight("@diff.minus").fg, bg = colors.sumiInk4 },
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
                    Orgmode,
                    -- Align Right
                    {
                        provider = "%=",
                    },
                    Buffers,
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
                            filetype = { "fugitive", "Trouble", "dashboard", ".*neogit.*", "Overseer.*" },
                        }, args.buf)
                    end,
                },
            }
        end,
    },
}
