-- Configuration for autolist.nvim
-- Automatic list continuation and formatting for markdown and other formats

local ok, autolist = pcall(require, "autolist")
if ok then
	-- Cache modules for efficiency
	local autolist_utils = require("autolist.utils")
	local autolist_config = require("autolist.config")

	-- Define list patterns
	local list_patterns = {
		unordered = "[-+*]", -- - + *
		digit = "%d+[.)]", -- 1. 2. 3.
		ascii = "%a[.)]", -- a) b) c)
		roman = "%u*[.)]", -- I. II. III.
		latex_item = "\\item",
	}

	-- Filetypes that support autolist
	local supported_filetypes = {
		markdown = true,
		text = true,
		gitcommit = true,
		tex = true,
		plaintex = true,
	}

	autolist.setup({
		enabled = true,
		colon = {
			indent = true, -- If in list and line ends in `:` then create list
			indent_raw = true, -- Above, but doesn't need to be in a list to work
			preferred = "-", -- What the new list starts with
		},
		cycle = {
			"-",   -- Cycle through list types
			"*",
			"1.",
			"1)",
			"a)",
			"I.",
		},
		lists = {
			markdown = {
				list_patterns.unordered,
				list_patterns.digit,
				list_patterns.ascii,
				list_patterns.roman,
			},
			text = {
				list_patterns.unordered,
				list_patterns.digit,
				list_patterns.ascii,
				list_patterns.roman,
			},
			gitcommit = {
				list_patterns.unordered,
				list_patterns.digit,
			},
			tex = { list_patterns.latex_item },
			plaintex = { list_patterns.latex_item },
		},
		checkbox = {
			left = "%[",
			right = "%]",
			fill = "x",
		},
	})

	-- Set up key mappings for autolist functionality
	-- These mappings are filetype-specific and will only work in relevant filetypes
	local augroup = vim.api.nvim_create_augroup("AutolistKeymaps", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = { "markdown", "text", "gitcommit", "tex", "plaintex" },
		callback = function()
			-- Custom function to handle Enter key with colon detection
			-- Inserts an extra newline before bullet list when line ends with colon
			-- This ensures markdown renders the list correctly (requires blank line before list)
			local function handle_enter_with_colon()
				local bufnr = vim.api.nvim_get_current_buf()
				local cursor = vim.api.nvim_win_get_cursor(0)
				local line_num = cursor[1] - 1 -- Convert to 0-indexed for get_lines
				local line = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1] or ""
				
				-- Check if the line ends with a colon (ignoring trailing whitespace)
				local trimmed_line = line:match("^%s*(.-)%s*$")
				if trimmed_line:match(":$") then
					-- Save the indentation from the colon line
					local colon_indent = line:match("^%s*")
					-- Get the tab character/string from autolist config
					local tab = autolist_config.tab or "  "
					-- Get preferred bullet marker from colon config
					local preferred = autolist_config.colon.preferred or "-"
					
					-- Line ends with colon: insert Enter to create new line
					vim.cmd("normal! a\r")
					-- Schedule the blank line insertion and bullet creation
					vim.schedule(function()
						local current_cursor = vim.api.nvim_win_get_cursor(0)
						local current_line_0idx = current_cursor[1] - 1 -- 0-indexed for buffer operations
						-- Insert blank line at current position
						vim.api.nvim_buf_set_lines(bufnr, current_line_0idx, current_line_0idx, false, { "" })
						-- The bullet should be on the line after the blank line
						-- For buffer operations (0-indexed): current_line_0idx + 1
						-- For cursor operations (1-indexed): current_line_0idx + 2
						local bullet_line_0idx = current_line_0idx + 1 -- 0-indexed
						local bullet_line_1idx = current_line_0idx + 2 -- 1-indexed
						
						-- Get the current content of the bullet line (if any)
						local current_bullet_line = vim.api.nvim_buf_get_lines(bufnr, bullet_line_0idx, bullet_line_0idx + 1, false)[1] or ""
						-- Manually create the bullet with correct indentation
						-- Format: tab + colon_indent + preferred + " "
						local bullet = tab .. colon_indent .. preferred .. " "
						-- Set the line with the bullet, preserving any existing content (strip leading whitespace)
						local new_line = bullet .. current_bullet_line:gsub("^%s*", "", 1)
						vim.api.nvim_buf_set_lines(bufnr, bullet_line_0idx, bullet_line_0idx + 1, false, { new_line })
						-- Move cursor to after the bullet (1-indexed for cursor)
						vim.api.nvim_win_set_cursor(0, { bullet_line_1idx, #bullet })
					end)
				else
					-- Normal behavior: Enter + AutolistNewBullet
					vim.cmd("normal! a\r")
					vim.cmd("AutolistNewBullet")
				end
			end

			-- Insert mode mappings
			vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<cr>", { buffer = true, desc = "Autolist: Indent list" })
			vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<cr>", { buffer = true, desc = "Autolist: Dedent list" })
			vim.keymap.set("i", "<CR>", handle_enter_with_colon, { buffer = true, desc = "Autolist: New bullet (with colon handling)" })

			-- Normal mode mappings
			vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", { buffer = true, desc = "Autolist: New bullet below" })
			vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", { buffer = true, desc = "Autolist: New bullet above" })
			vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>", { buffer = true, desc = "Autolist: Toggle checkbox" })
			vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Recalculate list" })

			-- Cycle list types with dot-repeat
			vim.keymap.set("n", "<leader>cn", autolist.cycle_next_dr, { buffer = true, expr = true, desc = "Autolist: Cycle next" })
			vim.keymap.set("n", "<leader>cp", autolist.cycle_prev_dr, { buffer = true, expr = true, desc = "Autolist: Cycle prev" })

			-- Recalculate list on edit
			vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Indent and recalculate" })
			vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Dedent and recalculate" })
			vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Delete line and recalculate" })
			vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Delete selection and recalculate" })

			-- Recalculate list on line reordering (move lines up/down)
			-- Move line down: delete and paste below
			vim.keymap.set("n", "<A-j>", "ddp<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Move line down and recalculate" })
			-- Move line up: delete and paste above
			vim.keymap.set("n", "<A-k>", "ddkP<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Move line up and recalculate" })
			-- Visual mode: move selection down
			vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Move selection down and recalculate" })
			-- Visual mode: move selection up
			vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Move selection up and recalculate" })
			-- Paste operations that might affect lists
			vim.keymap.set("n", "p", "p<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Paste and recalculate" })
			vim.keymap.set("n", "P", "P<cmd>AutolistRecalculate<cr>", { buffer = true, desc = "Autolist: Paste before and recalculate" })
		end,
	})

	-- Function to recalculate all lists in the buffer
	local function recalculate_all_lists()
		if not autolist or not autolist.recalculate then
			return
		end

		local ft = vim.bo.filetype
		local list_types = autolist_config.lists[ft]
		
		if not list_types then
			return
		end

		-- Save current view (cursor + scroll position)
		local view = vim.fn.winsaveview()
		local bufnr = vim.api.nvim_get_current_buf()
		
		-- Read all lines at once for efficiency
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local line_count = #lines
		
		-- Find all ordered list starts and recalculate each
		local processed_lines = {}
		
		for i = 1, line_count do
			local line = lines[i]
			if line and autolist_utils.is_list(line, list_types) then
				-- Check if this is an ordered list (is_ordered returns a new value if ordered, nil otherwise)
				local is_ordered = autolist_utils.is_ordered(line)
				if is_ordered then
					-- Find the start of this list
					local list_start = autolist_utils.get_list_start(i, list_types)
					if list_start and list_start > 0 and list_start <= line_count and not processed_lines[list_start] then
						processed_lines[list_start] = true
						-- Move cursor to list start and recalculate
						vim.api.nvim_win_set_cursor(0, { list_start, 0 })
						-- Use pcall to handle any errors gracefully
						pcall(autolist.recalculate)
					end
				end
			end
		end
		
		-- Restore original view to avoid scroll jumps on save
		vim.fn.winrestview(view)
	end

	-- Recalculate lists on document save
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = augroup,
		pattern = "*",
		callback = function()
			-- Only recalculate if autolist is enabled and filetype matches
			if supported_filetypes[vim.bo.filetype] then
				recalculate_all_lists()
			end
		end,
		desc = "Autolist: Recalculate lists before saving",
	})
end
