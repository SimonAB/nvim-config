-- Essential Core Key Mappings
-- Purpose: Provide fast, plugin-independent keymaps for early startup

local map = vim.keymap.set

-- ============================================================================
-- GENERAL KEYMAPS (NO PLUGIN DEPENDENCIES)
-- ============================================================================

-- Better window navigation (works from normal and terminal mode)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Terminal mode window navigation (allows moving out of terminal)
map("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Move to left window from terminal" })
map("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Move to bottom window from terminal" })
map("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Move to top window from terminal" })
map("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Move to right window from terminal" })

-- Window resizing
map("n", "<S-Up>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<S-Down>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<S-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<S-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

map("n", "<leader>Wk", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<leader>Wj", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<leader>Wh", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<leader>Wl", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better paste
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- ============================================================================
-- CORE LEADER KEYMAPS (NO PLUGIN DEPENDENCIES)
-- ============================================================================

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Quick save" })
map("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Hide Highlight" })

-- Split commands in Split group (using | since S is for Search)
map("n", "<leader>|v", "<cmd>vsplit<CR>", { desc = "Split Vertical" })
map("n", "<leader>|h", "<cmd>split<CR>", { desc = "Split Horizontal" })

-- Toggle options (using Y prefix since T is for Terminal)
map("n", "<leader>Yw", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<leader>Yn", "<cmd>set number!<CR>", { desc = "Toggle line numbers" })

return {}

