local alpha = require("alpha")

-- Set header
local header = {
    type = "text",
    val = {
        "                               ",
        "                               ",
        "                               ",
        "                               ",
        "                               ",
        "         -╲         '-         ",
        "       -' :╲        │ '-       ",
        "     -'   : ╲       │   '-     ",
        "   -'·    :  ╲      │     '-   ",
        "  '.-.·   :   ╲     │       │  ",
        "  │. .-·  :    ╲    │       │  ",
        "  │ . .-· :     ╲   │       │  ",
        "  │. . .-·;      ╲  │       │  ",
        "  │ . . .-│       ╲ │       │  ",
        "  │. . . .│╲       ╲│       │  ",
        "  │ . . . │ ╲       ;-      │  ",
        "  │. . . .│  ╲      :·-     │  ",
        "  │ . . . │   ╲     : .-    │  ",
        "  │. . . .│    ╲    :. .-   │  ",
        "  `- . . .│     ╲   : . .- -'  ",
        "    `- . .│      ╲  :. ..-'    ",
        "      `-. │       ╲ :..-'      ",
        "         `│        ╲;-'        ",
        "                               ",
        "                               ",
    },
    opts = { position = "center", hl = "@boolean" },
}

local plugins_loaded = {
    type = "text",
    val = function()
        local lazy_stats = require("lazy").stats()
        local plugin_count = lazy_stats.count
        local loaded_plugins = lazy_stats.loaded
        return "" .. loaded_plugins .. "/" .. plugin_count .. " plugins  loaded!"
    end,

    opts = { hl = "@conditional", position = "center" },
}

vim.api.nvim_set_hl(0, "AlphaPluginUpdate", { link = "@string" })
local plugin_info = {
    type = "text",
    val = function()
        if require("lazy.status").has_updates() then
            vim.api.nvim_set_hl(0, "AlphaPluginUpdate", { link = "@exception" })
            return "Plugin updates available!"
        else
            vim.api.nvim_set_hl(0, "AlphaPluginUpdate", { link = "@string" })
            return "All plugins up to date"
        end
    end,

    opts = {
        hl = "AlphaPluginUpdate",
        position = "center",
    },
}

local datetime = {
    type = "text",
    val = function()
        return vim.fn.strftime("%c")
    end,
    opts = { hl = "@decorator", position = "center" },
}

-- Menu
local button = function(sc, txt, keybind)
    local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

    local opts = {
        position = "center",
        text = txt,
        shortcut = sc,
        cursor = 4,
        width = 30,
        align_shortcut = "right",
        hl_shortcut = "Number",
        hl = "Function",
    }
    if keybind then
        opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
    end

    return {
        type = "button",
        val = txt,
        on_press = function()
            local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
            vim.api.nvim_feedkeys(key, "normal", false)
        end,
        opts = opts,
    }
end

-- Set menu
local buttons = {
    type = "group",
    val = {
        button("e", "  New File", ":ene <BAR> startinsert <CR>"),
        button("f", "  Find File", ":Telescope find_files<CR>"),
        button("r", "  Recent", ":Telescope oldfiles<CR>"),
        button("s", "  Settings", "<cmd>e ~/.config/nvim/<CR>"),
        button("u", "  Update Plugins", ":Lazy sync<CR>"),
        button("q", "  Quit", ":qa<CR>"),
    },
    opts = { spacing = 0 },
}

-- Footer 2, fortune
local fortune = {
    type = "text",
    val = require("alpha.fortune")(),
    opts = { position = "center", hl = "Comment" },
}

local padding = function(pad_amount)
    return { type = "padding", val = pad_amount }
end
local opts = {
    layout = {
        padding(4),
        header,
        padding(4),
        datetime,
        padding(1),
        plugin_info,
        padding(1),
        plugins_loaded,
        padding(4),
        buttons,
        padding(4),
        fortune,
    },
    opts = { margin = 5 },
}
-- Send config to alpha
alpha.setup(opts)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "alpha",
    desc = "Alpha Main Handler",
    callback = function()
        vim.opt_local.cursorline = false

        local alpha_timer = vim.loop.new_timer()
        alpha_timer:start(
            50,
            1000,
            vim.schedule_wrap(function()
                pcall(vim.cmd, "AlphaRedraw")
            end)
        )

        vim.api.nvim_create_autocmd("BufUnload", {
            buffer = 0,
            desc = "Shut down alpha timer",
            callback = function(input)
                alpha_timer:close()
            end,
        })
    end,
})
