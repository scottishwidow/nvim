-- keymaps

vim.keymap.set("n", "<leader>pv", ":Ex<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<ESC>", { noremap = true, silent = true })

-- telescope

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>gf", builtin.git_files, {})

-- window switch

vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })
