local keymap = vim.keymap
local builtin = require("telescope.builtin")
-- Select All

keymap.set("n", "<C-a>", "gg<S-v>G")

-- FzF

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
vim.keymap.set("n", "<leader>rg", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
