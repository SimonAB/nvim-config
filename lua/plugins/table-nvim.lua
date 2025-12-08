-- Configuration for table-nvim
-- Automatic table formatting and alignment for Markdown tables
-- Plugin automatically handles *.md and *.mdx files via built-in autocmds

local ok, table_nvim = pcall(require, "table-nvim")
if not ok then
	vim.notify("table-nvim not found", vim.log.levels.WARN)
	return
end

-- Set up table-nvim with configuration
-- The plugin automatically:
-- - Formats tables on InsertLeave for *.md and *.mdx files
-- - Sets up keymaps on BufEnter for *.md and *.mdx files
table_nvim.setup({
	-- Insert a space around column separators (e.g., "| col |" instead of "|col|")
	padd_column_separators = true,
	-- Key mappings use defaults (see plugin README for available mappings)
	-- Default mappings: <TAB>/<S-TAB> for navigation, <A-k>/<A-j> for rows, etc.
})

-- Extend support for Quarto files (*.qmd) which use markdown syntax
-- The plugin's internal modules are used to replicate functionality for additional filetypes
local ok_utils, utils = pcall(require, "table-nvim.utils")
local ok_mdtable, MdTable = pcall(require, "table-nvim.md_table")
local ok_maps, maps = pcall(require, "table-nvim.keymaps")
local ok_edit, edit = pcall(require, "table-nvim.edit")
local ok_nav, nav = pcall(require, "table-nvim.nav")

if ok_utils and ok_mdtable and ok_maps then
	local api = vim.api
	local ts = vim.treesitter

	local extended_group = api.nvim_create_augroup("table-nvim-extended", { clear = true })

	-- Format tables on InsertLeave for Quarto files
	api.nvim_create_autocmd({ "InsertLeave" }, {
		group = extended_group,
		pattern = { "*.qmd" },
		callback = function()
			local root = utils.get_tbl_root(ts.get_node())
			if not root then
				return
			end
			MdTable:new(root):render()
		end,
		desc = "Table-nvim: Format tables in Quarto files",
	})

	-- Set up keymaps on BufEnter for Quarto files
	api.nvim_create_autocmd({ "BufEnter" }, {
		group = extended_group,
		pattern = { "*.qmd" },
		callback = function(opts)
			maps.set_keymaps(opts.buf)
		end,
		desc = "Table-nvim: Set up keymaps for Quarto files",
	})
end

-- Set up custom key mappings under <leader>Kt for table operations
-- These mappings work in markdown and quarto files
if ok_utils and ok_mdtable and ok_edit and ok_nav then
	local api = vim.api
	local ts = vim.treesitter

	local keymap_group = api.nvim_create_augroup("TableNvimKeymaps", { clear = true })

	-- Register which-key group for table operations
	local ok_wk, wk = pcall(require, "which-key")
	if ok_wk then
		wk.add({
			{ "<leader>Kt", group = "Table" },
		})
	end

	-- Helper function to set up key mappings
	local function setup_table_keymaps(bufnr)
		-- Format/realign table
		vim.keymap.set("n", "<leader>Ktf", function()
			local root = utils.get_tbl_root(ts.get_node())
			if root then
				MdTable:new(root):render()
			end
		end, { buffer = bufnr, desc = "Format table" })

		-- Navigation
		vim.keymap.set("n", "<leader>Ktn", function()
			nav.move(true)
		end, { buffer = bufnr, desc = "Next cell" })

		vim.keymap.set("n", "<leader>Ktp", function()
			nav.move(false)
		end, { buffer = bufnr, desc = "Previous cell" })

		-- Row operations
		vim.keymap.set("n", "<leader>Kto", function()
			edit.insert_row_down()
		end, { buffer = bufnr, desc = "Insert row below" })

		vim.keymap.set("n", "<leader>KtO", function()
			edit.insert_row_up()
		end, { buffer = bufnr, desc = "Insert row above" })

		vim.keymap.set("n", "<leader>KtJ", function()
			edit.move_row_down()
		end, { buffer = bufnr, desc = "Move row down" })

		vim.keymap.set("n", "<leader>KtK", function()
			edit.move_row_up()
		end, { buffer = bufnr, desc = "Move row up" })

		-- Column operations
		vim.keymap.set("n", "<leader>Kti", function()
			edit.insert_column_right()
		end, { buffer = bufnr, desc = "Insert column right" })

		vim.keymap.set("n", "<leader>KtI", function()
			edit.insert_column_left()
		end, { buffer = bufnr, desc = "Insert column left" })

		vim.keymap.set("n", "<leader>KtL", function()
			edit.move_column_right()
		end, { buffer = bufnr, desc = "Move column right" })

		vim.keymap.set("n", "<leader>KtH", function()
			edit.move_column_left()
		end, { buffer = bufnr, desc = "Move column left" })

		vim.keymap.set("n", "<leader>Ktdc", function()
			edit.delete_current_column()
		end, { buffer = bufnr, desc = "Delete column" })

		-- Table creation
		vim.keymap.set("n", "<leader>Ktt", function()
			edit.insert_table()
		end, { buffer = bufnr, desc = "Insert table" })

		vim.keymap.set("n", "<leader>KtT", function()
			edit.insert_table_alt()
		end, { buffer = bufnr, desc = "Insert table (no outline)" })
	end

	-- Set up key mappings for markdown and quarto filetypes
	api.nvim_create_autocmd("FileType", {
		group = keymap_group,
		pattern = { "markdown", "pandoc", "text", "quarto" },
		callback = function()
			setup_table_keymaps(api.nvim_get_current_buf())
		end,
		desc = "Table-nvim: Set up <leader>Kt keymaps",
	})

	-- Also set up keymaps for file patterns (in case filetype isn't set correctly)
	api.nvim_create_autocmd("BufEnter", {
		group = keymap_group,
		pattern = { "*.md", "*.mdx", "*.qmd", "*.pandoc", "*.txt" },
		callback = function(opts)
			-- Only set up if filetype matches or is markdown-like
			local ft = vim.bo[opts.buf].filetype
			if ft == "" or ft == "markdown" or ft == "pandoc" or ft == "text" or ft == "quarto" then
				setup_table_keymaps(opts.buf)
			end
		end,
		desc = "Table-nvim: Set up <leader>Kt keymaps for markdown files",
	})
end
