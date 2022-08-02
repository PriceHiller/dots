local file_loc = vim.fn.expand('%:p:h')

vim.opt.makeprg = 'docker build ' .. file_loc
