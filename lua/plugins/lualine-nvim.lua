-- Configuration for lualine.nvim
-- Status line with comprehensive information display

local ok, lualine = pcall(require, "lualine")
if ok then
	lualine.setup({
		options = {
			theme = "auto",
			component_separators = "┃",
			section_separators = "",
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})
end
