local keymap = vim.keymap

-- Navigation
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>m", ":NvimTreeFocus<CR>", { noremap = true, silent = true })

-- Pane Navigation
keymap.set("n", "<C-h>", "<C-w>h", opts) -- left
keymap.set("n", "<C-j>", "<C-w>j", opts) -- right
keymap.set("n", "<C-k>", "<C-w>k", opts) -- up
keymap.set("n", "<C-l>", "<C-w>l", opts) -- down

-- Window Splitting

keymap.set("n", "<leader>sv", ":vsplit<CR>", opts) -- vertical split
keymap.set("n", "<leader>sh", ":split<CR>", opts) -- horizontal split
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", opts) -- toggle minimize

-- Indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Comments
vim.api.nvim_set_keymap("n", "<C-_>", "gcc", { noremap = false })
vim.api.nvim_set_keymap("v", "<C-_>", "gcc", { noremap = false })



