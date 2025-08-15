-- Configuration for trouble.nvim
-- Diagnostics viewer with enhanced display

local ok, trouble = pcall(require, "trouble")
if ok then
	trouble.setup({
		-- Default configuration (shows diagnostics, quickfix, LSP, etc.)
		-- You can add more config here (e.g., icons, auto_open, use_diagnostic_signs, etc.)
	})
end
