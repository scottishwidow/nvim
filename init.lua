vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_set_keymap('n', '<leader>pv', ':Ex<CR>', { noremap = true, silent = true })
