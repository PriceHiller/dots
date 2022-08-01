local alpha = require('alpha')
local startify = require('alpha.themes.startify')
local dashboard = require('alpha.themes.dashboard')

-- Set header
local header = {
    type = 'text',
    val = {
        '                                   ',
        '                                   ',
        '                                   ',
        '   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ',
        '    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
        '          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ',
        '           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
        '          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
        '   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
        '  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
        ' ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
        ' ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ',
        '      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ',
        '       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ',
        '                                   ',
    },
    opts = {
        position = 'center',
        hl = 'Function',
    },
}

-- Subheader, plugin count
local get_plugins = function()
    local num_plugins_loaded = #vim.fn.globpath(vim.fn.stdpath('data') .. '/site/pack/packer/start', '*', 0, 1)
    local num_plugins_total = #vim.tbl_keys(packer_plugins)
    if num_plugins_total <= 1 then
        return num_plugins_loaded .. ' / ' .. num_plugins_total .. ' plugin  loaded'
    else
        return num_plugins_loaded .. ' / ' .. num_plugins_total .. ' plugins  loaded'
    end
end

local plugin_count = {
    type = 'text',
    val = {
        get_plugins(),
    },
    opts = {
        hl = 'Comment',
        position = 'center',
    },
}

-- Menu
local button = function(sc, txt, keybind)
    local sc_ = sc:gsub('%s', ''):gsub('SPC', '<leader>')

    local opts = {
        position = 'center',
        text = txt,
        shortcut = sc,
        cursor = 4,
        width = 30,
        align_shortcut = 'right',
        hl_shortcut = 'Number',
        hl = 'Function',
    }
    if keybind then
        opts.keymap = { 'n', sc_, keybind, { noremap = true, silent = true } }
    end

    return {
        type = 'button',
        val = txt,
        on_press = function()
            local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
            vim.api.nvim_feedkeys(key, 'normal', false)
        end,
        opts = opts,
    }
end

-- Set menu
local buttons = {
    type = 'group',
    val = {
        button('e', '  New File', ':ene <BAR> startinsert <CR>'),
        button('f', '  Find File', ':Telescope find_files<CR>'),
        button('r', '  Recent', ':Telescope oldfiles<CR>'),
        button('s', '  Settings', ':e ~/.config/nvim/<CR>'),
        button('u', '  Update Plugins', ':PackerSync<CR>'),
        button('q', '  Quit', ':qa<CR>'),
    },
    opts = {
        spacing = 0,
    },
}

-- Footer 2, fortune
local fortune = {
    type = 'text',
    val = require('alpha.fortune')(),
    opts = {
        position = 'center',
        hl = 'Comment',
    },
}

local padding = function()
    return { type = 'padding', val = 4 }
end
local opts = {
    layout = {
        padding(),
        header,
        padding(),
        plugin_count,
        padding(),
        buttons,
        padding(),
        fortune,
    },
    opts = {
        margin = 5,
    },
}
-- Send config to alpha
alpha.setup(opts)

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'alpha',
    callback = function()
        vim.opt_local.cursorline = false
    end,
})
