local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  spec = {
  { import = "plugins" },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        update_focused_file = {
        enable = true,            -- Enables updating the tree when you change files
        update_cwd = true,        -- Updates the root directory of the tree to the current working directory
        ignore_list = {},         -- Files to ignore when updating
      },
      view = {
        adaptive_size = true,     -- Automatically adjusts the width of the tree window
      },
      renderer = {
        highlight_opened_files = "all",  -- Highlights the current file in the tree
          },
      })
    end,
  },
  { 
    "rose-pine/neovim", 
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        dark_variant = "main",
        bold_vert_split = false,
        dim_nc_background = false,
        disable_background = false,
        disable_float_background = false,
        disable_italics = false,
      })
      vim.cmd("colorscheme rose-pine")
    end,
  },
}
})





