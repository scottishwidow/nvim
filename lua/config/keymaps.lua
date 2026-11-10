local map = vim.keymap.set

map("n", "+", "<C-a>", { desc = "Increment number" })
map("n", "-", "<C-x>", { desc = "Decrement number" })
map("n", "<C-a>", "gg<S-v>G", { desc = "Select full buffer" })

map("n", "<C-w><Left>", "<C-w><", { desc = "Decrease window width" })
map("n", "<C-w><Right>", "<C-w>>", { desc = "Increase window width" })
map("n", "<C-w><Up>", "<C-w>+", { desc = "Increase window height" })
map("n", "<C-w><Down>", "<C-w>-", { desc = "Decrease window height" })

map("n", "<leader>ff", ":find ", { desc = "Find file" })
map("n", "<leader>fg", ":grep ", { desc = "Search text" })
map("n", "<leader>fb", ":buffer ", { desc = "Switch buffer" })
