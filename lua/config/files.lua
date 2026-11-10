local oil = require("oil")

oil.setup({
  default_file_explorer = true,
  use_default_keymaps = false,
  view_options = { show_hidden = false },
  keymaps = {
    ["<CR>"] = { "actions.select", desc = "Open file or directory" },
    ["-"] = { "actions.parent", desc = "Go to parent directory" },
    ["_"] = { "actions.open_cwd", desc = "Go to current working directory" },
    ["g."] = { "actions.toggle_hidden", desc = "Show or hide hidden files" },
    ["g?"] = { "actions.show_help", desc = "Show this cheat sheet" },
    ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
    ["<C-s>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
    ["<C-p>"] = { "actions.preview", desc = "Preview file" },
    ["q"] = { "actions.close", desc = "Close file manager" },
  },
})

vim.keymap.set("n", "<leader>e", function()
  oil.open()
end, { desc = "Open file manager" })
