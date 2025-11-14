-- Configuration for lualine.nvim
-- Status line with comprehensive information display

local ok, lualine = pcall(require, "lualine")
if ok then
	-- Custom component for pretty path formatting (similar to LazyVim)
	--- Formats file paths intelligently, showing only necessary parent directories
	---@param opts table Component options
	---@return string Formatted path
	local function pretty_path(opts)
		local filepath = vim.api.nvim_buf_get_name(0)
		
		-- Handle buffers without files (scratch buffers, etc.)
		if filepath == "" then
			return "[No Name]"
		end

		local path_sep = package.config:sub(1, 1) -- Get path separator for OS
		local cwd = vim.fn.getcwd()
		
		-- Normalise paths
		filepath = vim.fn.fnamemodify(filepath, ":p")
		cwd = vim.fn.fnamemodify(cwd, ":p")

		-- Make path relative to cwd if possible
		if vim.startswith(filepath, cwd) then
			filepath = filepath:sub(#cwd + 1)
			if filepath:sub(1, 1) == path_sep then
				filepath = filepath:sub(2)
			end
		else
			-- If not in cwd, use home directory as reference
			local home = vim.fn.expand("~")
			if vim.startswith(filepath, home) then
				filepath = "~" .. filepath:sub(#home + 1)
			end
		end

		-- Handle empty path (file in cwd root)
		if filepath == "" or filepath == nil then
			return vim.fn.expand("%:t")
		end

		-- Split path into components
		local parts = {}
		for part in filepath:gmatch("[^" .. path_sep .. "]+") do
			if part ~= "" then
				table.insert(parts, part)
			end
		end

		-- If only one part (just filename), return it
		if #parts == 1 then
			return parts[1]
		end

		-- Get filename (last part)
		local filename = parts[#parts]
		table.remove(parts)

		-- If only one directory, show it with filename
		if #parts == 1 then
			return parts[1] .. path_sep .. filename
		end

		-- For multiple directories, show first letter of intermediate dirs
		-- and full name of last directory (similar to LazyVim)
		local result = {}
		for i = 1, #parts - 1 do
			local dir = parts[i]
			if #dir > 0 then
				table.insert(result, dir:sub(1, 1))
			end
		end
		-- Add last directory in full
		table.insert(result, parts[#parts])
		-- Add filename
		table.insert(result, filename)

		return table.concat(result, path_sep)
	end

	lualine.setup({
		options = {
			theme = "auto",
			component_separators = "┃",
			section_separators = { left = '', right = '' },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { { pretty_path, path = 1 } },
			lualine_x = { "filetype", "lsp_status" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})
end

