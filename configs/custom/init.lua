-- minimal configuration
require("config.lazy")
require("config.options")
require("config.keymaps")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
  },
})
