-- minimal configuration
require("config.lazy")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- keymaps

vim.keymap.set("n", "<leader>pv", ":Ex<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

