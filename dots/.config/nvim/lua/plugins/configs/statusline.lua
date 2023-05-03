local util = require("utils.funcs")
local present, lualine = pcall(require, "lualine")
if not present then
    return
end

-- Thanks to rockyzhang24 (github.com/rockyzhang24)

local function simplifiedMode(str)
    return "  " .. (str == "V-LINE" and "VL" or (str == "V-BLOCK" and "VB" or str:sub(1, 1)))
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
        local msg = "No Active Lsp"
        local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
            return msg
        else
            msg = ""
            for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    if msg == "" then
                        msg = client.name
                    else
                        msg = msg .. ", " .. client.name
                    end
                end
            end
        end
        return msg
    end,
    icon = " LSP:",
    color = { fg = "#957fb8" },
}

local LuaLineDateTimeHls = function()
    return {
        normal = {
            fg = "#957FB8",
            bg = util.get_color("lualine_c_normal", "bg#"),
        },
        hour_changed = {
            fg = "#FFA066",
            bg = util.get_color("lualine_c_normal", "bg#"),
        },
    }
end

vim.api.nvim_set_hl(0, "LuaLineDateTime", LuaLineDateTimeHls().normal)

local datetime_section = function()
    return os.date("%I:%M %p")
end

lualine.setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {},
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
            {
                "datetime",
                fmt = datetime_section,
                color = "LuaLineDateTime",
                separator = {
                    right = "%#lualine_transitional_lualine_b_normal_to_lualine_c_normal#",
                },
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
})

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
        local timer = vim.loop.new_timer()
        timer:start(
            30,
            0,
            vim.schedule_wrap(function()
                lualine.refresh({
                    place = macro_refresh_places,
                })
            end)
        )
        timer:close()
    end,
})

local last_date_hour = tonumber(os.date("%H"))
local date_timer = vim.loop.new_timer()
date_timer:start(
    100,
    1000,
    vim.schedule_wrap(function()
        vim.api.nvim_set_hl(0, "LuaLineDateTime", LuaLineDateTimeHls().normal)
        local curr_date_hour = tonumber(os.date("%H"))
        if curr_date_hour ~= last_date_hour then
            vim.api.nvim_set_hl(0, "LuaLineDateTime", LuaLineDateTimeHls().hour_changed)
        end
        last_date_hour = curr_date_hour
        lualine.refresh({
            place = { "datetime" },
        })
    end)
)
