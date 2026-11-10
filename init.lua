if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "This configuration requires Neovim 0.12 or later.", "ErrorMsg" } }, true, {})
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.filetypes")
require("config.plugins")
require("config.treesitter")
require("config.lsp")
require("config.files")
require("config.git")
require("config.terminal")
require("config.keymaps")
require("config.autocmds")
