-- Configuration for bufferline.nvim
-- Buffer tabs with enhanced visual features

local ok, bufferline = pcall(require, "bufferline")
if ok then
	bufferline.setup({
		options = {
			diagnostics = "nvim_lsp",
			always_show_bufferline = false, -- Don't always show bufferline
			show_buffer_icons = true,
			show_buffer_close_icons = true,
			show_close_icon = true,
			show_tab_indicators = true,
			-- Hover events (requires mousemoveevent to be enabled)
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
			-- Offset for nvimtree file explorer
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					text_align = "left",
				},
			},
		},
	})
end
