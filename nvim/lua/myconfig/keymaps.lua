local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<C-b>", ":NvimTreeToggle<CR>", opts)
map("n", "<C-p>", ":Telescope find_files<CR>", opts)
map("n", "<C-S-p>", ":Telescope commands<CR>", opts)
map("n", "<Tab>", ":bnext<CR>", opts)
map("n", "<S-Tab>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bdelete<CR>", opts)
