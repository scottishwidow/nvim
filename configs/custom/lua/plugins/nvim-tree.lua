return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      update_focused_file = {
        enable = true, -- Enables updating the tree when you change files
        update_cwd = true, -- Updates the root directory of the tree to the current working directory
        ignore_list = {}, -- Files to ignore when updating
      },
      view = {
        adaptive_size = true, -- Automatically adjusts the width of the tree window
      },
      renderer = {
        highlight_opened_files = "all", -- Highlights the current file in the tree
      },
    })
  end,
}
