-- Configuration for bufferline.nvim
-- Buffer tabs with enhanced visual features

local ok, bufferline = pcall(require, "bufferline")
if ok then
	bufferline.setup({
	options = {
		diagnostics = "nvim_lsp", -- Show LSP diagnostics in bufferline
		separator_style = "slant", -- Use slanted separators between buffers
		show_buffer_icons = true, -- Show filetype icons
		show_buffer_close_icons = true, -- Show close icons on buffers
		show_close_icon = true, -- Show close icon on the right
		show_tab_indicators = true, -- Show tab indicators
	},
	-- You can add more config here (e.g., custom highlights, offsets, etc.)
	})
end
