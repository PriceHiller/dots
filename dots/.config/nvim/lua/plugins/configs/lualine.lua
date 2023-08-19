---@diagnostic disable: missing-fields
return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function()
            local present, lualine = pcall(require, "lualine")
            if not present then
                return
            end

            -- Thanks to rockyzhang24 (github.com/rockyzhang24)

            local function simplifiedMode(str)
                return "󰀘  " .. (str == "V-LINE" and "VL" or (str == "V-BLOCK" and "VB" or str:sub(1, 1)))
            end

            -- For location, show total lines
            local function customLocation(str)
                return string.gsub(str, "%w+", "%1" .. "/%%L", 1)
            end

            -- For progress, add a fancy icon
            local function customProgress(str)
                return " " .. str
            end

            -- For filename, show the filename and the filesize
            local function fileNameAndSize(str)
                -- For doc, only show filename
                if string.find(str, ".*/doc/.*%.txt") then
                    str = vim.fn.expand("%:t")
                end
                local size = require("lualine.components.filesize")()
                return size == "" and str or str .. " [" .. size .. "]"
            end

            local function show_macro_recording()
                local recording_register = vim.fn.reg_recording()
                if recording_register == "" then
                    return ""
                else
                    return "Recording @" .. recording_register
                end
            end

            local show_lsp_name = {
                function()
                    local buf_ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
                    local clients = vim.lsp.get_clients({})
                    if next(clients) == nil then
                        return "No Active Lsp"
                    else
                        local msg = nil
                        for _, client in ipairs(clients) do
                            local filetypes = client.config.filetypes
                            -- Prep filetypes for indexing, some language servers only register with a single filetype so we need to
                            -- convert them into a blob so vim.fn.index doesn't throw a fit
                            if type(filetypes) == "string" then
                                filetypes = { filetypes }
                            end

                            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                                if not msg then
                                    msg = client.name
                                else
                                    msg = msg .. ", " .. client.name
                                end
                            end
                        end
                        return msg or "No Active Lsp"
                    end
                end,
                icon = " LSP:",
                color = { fg = "#957fb8" },
            }

            local macro_refresh_places = { "statusline", "winbar" }
            vim.api.nvim_create_autocmd("RecordingEnter", {
                callback = function()
                    lualine.refresh({
                        place = macro_refresh_places,
                    })
                end,
            })

            vim.api.nvim_create_autocmd("RecordingLeave", {
                callback = function()
                    lualine.refresh({
                        place = macro_refresh_places,
                    })
                end,
            })

            return {
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = { "alpha", "neo-tree" },
                    always_divide_middle = true,
                    globalstatus = true,
                },
                winbar = {
                    lualine_a = {
                        {
                            "filename",
                            path = 1,
                        },
                    },
                    lualine_b = {
                        {
                            "macro-recording",
                            color = {
                                fg = "#FF9E3B",
                            },
                            fmt = show_macro_recording,
                        },
                        show_lsp_name,
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                        },
                    },
                    lualine_c = {},
                    lualine_x = {
                        "encoding",
                        "fileformat",
                        "filetype",
                    },
                    lualine_y = {
                        {
                            "location",
                            fmt = customLocation,
                        },
                    },
                    lualine_z = {
                        {
                            "progress",
                            fmt = customProgress,
                        },
                    },
                },
                inactive_winbar = {
                    lualine_a = { { "filename", path = 1 } },
                    lualine_b = { show_lsp_name },
                    lualine_c = {},
                    lualine_x = {
                        "filetype",
                    },
                    lualine_y = {},
                    lualine_z = {},
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = simplifiedMode,
                        },
                        {
                            color = {
                                fg = "#C34043",
                                gui = "bold,italic",
                            },
                            function()
                                local user = os.getenv("USER")
                                if user == "root" then
                                    return user
                                end
                                return ""
                            end,
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = "",
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                        },
                        {
                            "macro-recording",
                            color = {
                                fg = "#FF9E3B",
                            },
                            fmt = show_macro_recording,
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            path = 3,
                            symbols = {
                                modified = "[+]",
                                readonly = "[]",
                                unnamed = "[No Name]",
                            },
                            fmt = fileNameAndSize,
                        },
                    },

                    -- Right
                    lualine_x = {
                        {
                            function()
                                local lazy_stats = require("lazy").stats()
                                local plugin_count = lazy_stats.count
                                local loaded_plugins = lazy_stats.loaded
                                return "" .. loaded_plugins .. "/" .. plugin_count .. " "
                            end,
                        },
                        {
                            require("lazy.status").updates,
                            cond = require("lazy.status").has_updates,
                        },
                    },
                    lualine_y = {
                        {
                            "buffers",
                            mode = 2,
                            show_filename_only = false,
                        },
                    },
                    lualine_z = {
                        { "tabs" },
                    },
                },
                inactive_sections = {},
                tabline = {},
                extensions = {
                    "aerial",
                    "fugitive",
                    "nvim-tree",
                    "neo-tree",
                    "quickfix",
                    "toggleterm",
                },
            }
        end,
    },
}
