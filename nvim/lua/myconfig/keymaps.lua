local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<C-b>", ":NvimTreeToggle<CR>", opts)
map("n", "<C-p>", ":Telescope find_files<CR>", opts)
map("n", "<C-S-p>", ":Telescope commands<CR>", opts)
map("n", "<Tab>", ":bnext<CR>", opts)
map("n", "<S-Tab>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bdelete<CR>", opts)

-- Terminal keymaps (using toggleterm)
-- Note: <C-\> is handled by toggleterm's open_mapping in settings.lua
map("n", "<C-t>", ":ToggleTerm<CR>", opts) -- Ctrl+t as alternative
map("t", "<C-t>", "<C-\\><C-n>:ToggleTerm<CR>", opts)
map("n", "<F12>", ":ToggleTerm<CR>", opts) -- F12 as backup option
map("t", "<F12>", "<C-\\><C-n>:ToggleTerm<CR>", opts)

-- Additional terminal keymaps
map("t", "<Esc>", "<C-\\><C-n>", opts) -- Easy escape from terminal mode
map("n", "<leader>tf", ":ToggleTerm direction=float<CR>", opts) -- Floating terminal
map("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", opts) -- Horizontal terminal
map("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>", opts) -- Vertical terminal

-- Simple terminal commands that should work even without toggleterm
map("n", "<leader>t", ":terminal<CR>", opts) -- Simple terminal in current buffer
map("n", "<leader>ts", ":split | terminal<CR>", opts) -- Terminal in horizontal split
