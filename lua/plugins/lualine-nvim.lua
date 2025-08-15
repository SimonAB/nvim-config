-- Configuration for lualine.nvim
-- Status line with comprehensive information display

local ok, lualine = pcall(require, "lualine")
if ok then
	lualine.setup({
		options = {
			theme = "auto", -- Use colorscheme's theme automatically
			component_separators = "|", -- Separator between components
			section_separators = "", -- No section separators
		},
		sections = {
			lualine_a = { "mode" }, -- Show current mode
			lualine_b = { "branch", "diff", "diagnostics" }, -- Git branch, diff, diagnostics
			lualine_c = { "filename" }, -- Current filename
			lualine_x = { "encoding", "fileformat", "filetype" }, -- Encoding, file format, type
			lualine_y = { "progress" }, -- Progress through file
			lualine_z = { "location" }, -- Cursor location
		},
		-- You can add more config here (e.g., tabline, extensions, etc.)
	})
end
