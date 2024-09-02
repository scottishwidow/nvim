return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  config = function()
    require("nvim-tree").setup({
      filters = {
        dotfiles = true,  -- Set to true to hide dotfiles
      },
    })
  end
}

