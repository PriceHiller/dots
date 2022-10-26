local file_loc = vim.fn.expand('%:p:h')

vim.opt_local.makeprg = 'docker build ' .. file_loc
